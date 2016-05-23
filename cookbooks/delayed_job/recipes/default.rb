#
# Cookbook Name:: delayed_job
# Recipe:: default
#
require 'socket'

if ['solo', 'app', 'app_master'].include?(node[:instance_role]) || (node[:instance_role] == "util" && node[:name] !~ /^(solr|mongodb|redis|memcache)/)
  node[:applications].each do |app_name,data|
  
    # determine the number of workers to run based on instance size
    if node[:instance_role] == 'solo'
      worker_count = 1
    else
      case node[:ec2][:instance_type]
      when /\.small$/ then worker_count = 2
      when /\.(medium|large)$/ then worker_count = 4
      when /\.xlarge$/ then worker_count = 8
      else 
        worker_count = 2
      end
    end
    
    # determine the queues for this instance
    if node[:instance_role] == 'solo'
      queues = "" # i.e. all
    elsif node[:instance_role] == 'util'
      queues = "export,europeana,flickr"
    else # app instances
      queues = Socket.gethostname
    end
    
    remote_file "/usr/local/bin/dj" do
      source "dj"
      owner "root"
      group "root"
      mode 0755
    end
    
    worker_count.times do |count|
      template "/etc/monit.d/delayed_job#{count+1}.#{app_name}.monitrc" do
        source "dj.monitrc.erb"
        owner "root"
        group "root"
        mode 0644
        variables({
          :app_name => app_name,
          :user => node[:owner_name],
          :worker_name => "#{app_name}_delayed_job#{count+1}",
          :framework_env => node[:environment][:framework_env],
          :queues => queues
        })
      end
    end
    
    execute "monit reload" do
       action :run
       epic_fail true
    end
      
  end
end
