#
# Cookbook Name:: utility_config
# Recipe:: default
#

# Set your application name here
appname = "europeana19141918"

# Specify the application configuration files to copy from the application 
# master to utility instances, as paths relative to "/data/#{appname}", i.e.
# all paths should start with "shared/" or "current/". Entire directories can
# also be listed and will be copied recursively.
config_files = [
  "shared/config/environments",
  "shared/config/initializers",
  "shared/config/s3.yml"
]


if node[:instance_role] == 'util'
  require 'fileutils'
  
  run_for_app(appname) do |app_name, data|
    
    ey_cloud_report "Utility config" do
      message "copying application configuration files"
    end
    
    app_master = node[:master_app_server][:private_dns_name]
    
    config_files.each do |file_name|
      file_path = "/data/#{app_name}/#{file_name}"
      file_dir = File.dirname(file_path)
      
      if !File.exists?(file_dir)
        Chef::Log.info "Creating directory \"#{file_dir}\""
        FileUtils.mkdir(file_dir)
      end
      
      if File.directory?(file_dir)
        Chef::Log.info "Copying \"#{file_path}\" from application master"
        
        execute "copy #{file_path}" do
          command "scp -pr -o StrictHostKeyChecking=no -i /home/#{node[:owner_name]}/.ssh/internal #{node[:owner_name]}@#{app_master}:#{file_path} #{file_dir}/"
          user node[:owner_name]
          cwd "/data/#{app_name}"
        end
      else
        Chef::Log.error "Can not copy \"#{file_path}\" from application master because \"#{file_dir}\" is not a directory"
      end
      
    end

  end
end
