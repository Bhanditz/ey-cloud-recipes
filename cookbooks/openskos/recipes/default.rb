#
# Cookbook Name:: openskos
# Recipe:: default
#

# @todo Set Solr config from solr utility instance

node[:applications].each do |app_name, data|
  
  app_dir = "/data/#{app_name}/current"
  app_shared_dir = "/data/#{app_name}/shared"
  openskos_config_file = "#{app_shared_dir}/config/application.ini"
  openskos_config_dist_file = "#{app_dir}/application/configs/application.ini.dist"
  solr_utility = node[:utility_instances].find { |utility| utility[:name] == node[:solr_utility_name] }
  
  if ! File.exists?(app_dir)
    Chef::Log.info "OpenSKOS was not configured because the app must be deployed first. Please deploy it then re-run custom recipes."
  elsif ! (File.exists?(openskos_config_file) || File.exists?(openskos_config_dist_file))
    Chef::Log.error "OpenSKOS was not configured because this does not appear to be an installation of OpenSKOS: no config file found at #{openskos_config_file} or #{openskos_config_dist_file}"
  else

    if ['app_master','app','solo','util'].include? node[:instance_role]
    
      ey_cloud_report "openskos" do
        message "configuring OpenSKOS"
      end
      
      env = node[:environment][:framework_env]
      openskos_config = node[:openskos_config]
      openskos_db_config = {}
      openskos_solr_config = {}
      
      chef_gem "iniparse" do
        source "http://rubygems.org"
        action :install
        version "1.1.6"
      end
      
      file openskos_config_file do
        content File.read( openskos_config_dist_file )
        action :create_if_missing
        owner node[:owner_name]
        group node[:owner_name]
        mode 0644
      end
      
      ruby_block "read database config from database.yml" do
        block do
          require "yaml"
          db_config = YAML.load( File.read( "#{app_dir}/config/database.yml" ) )[env]
          openskos_db_config = {}
          
          case db_config["adapter"]
            when "mysql", "mysql2"
              openskos_db_config["resources.db.adapter"] = "pdo_mysql"
            when "postgresql"
              openskos_db_config["resources.db.adapter"] = "pdo_pgsql"
            when "sqlite3"
              openskos_db_config["resources.db.adapter"] = "pdo_sqlite"
            else
              Chef::Log.error("Unknown database adapter: " + db_config["adapter"])
          end
          
          openskos_db_config["resources.db.params.host"]      = db_config["host"]
          openskos_db_config["resources.db.params.username"]  = db_config["username"]
          openskos_db_config["resources.db.params.password"]  = db_config["password"]
          openskos_db_config["resources.db.params.charset"]   = (db_config["encoding"] || "utf8")
          openskos_db_config["resources.db.params.dbname"]    = db_config["database"]
        end
      end
      
      ruby_block "check for solr utility host" do
        block do
          if solr_utility
            openskos_solr_config["resources.solr.host"] = solr_utility[:hostname]
          end
        end
      end
      
      ruby_block "write application.ini" do
        block do
          require "iniparse"
          openskos_ini = IniParse.parse( File.read( openskos_config_file ) )
          
          [ openskos_config, openskos_db_config, openskos_solr_config ].each do |config_hash|
            config_hash.each_pair do |key, setting|
              openskos_ini[env][key] = setting
            end
          end
          
          openskos_ini.save(openskos_config_file)
        end
      end
      
      cron "openskos process jobs" do
        action  :create
        minute  '*/10'
        hour    '*'
        day     '*'
        month   '*'
        weekday '*'
        command "php #{app_dir}/tools/jobs.php process"
        user node[:owner_name]
      end

    end
    
    if (solr_utility && (node[:instance_role] == 'util') && (solr_utility[:name] == node[:name])) || 
      (solr_utility.blank? && ['app_master','app','solo','util'].include?(node[:instance_role]))
      
      directory "/data/solr/openskos" do
        action :create
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
      end
      
      execute "install openskos solr config" do
        command "cp -r #{app_dir}/data/solr/conf /data/solr/openskos"
      end
    end
    
  end
  
end
