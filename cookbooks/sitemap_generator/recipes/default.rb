#
# Cookbook Name:: sitemap_generator
# Recipe:: default
#

# Set your application name here
appname = "europeana19141918"

# If you want to install on a specific utility instance rather than
# all application instances, uncomment and set the utility instance
# name here. Note that if you use a utility instance, your very first
# deploy may fail because the initial database migration will not have
# run by the time this executes on the utility instance. If that occurs
# just deploy again and the recipe should succeed.

#utility_name = nil
utility_name = "utility"

# Set to false if you do not want to ping search engines after refreshing the
# sitemap.
ping = false

# The hour at which the cron task should run
cron_hour = 3

# The minute at which the cron task should run
cron_minute = 15


if ! File.exists?("/data/#{appname}/current")
  Chef::Log.info "SitemapGenerator was not configured because the app must be deployed first. Please deploy it then re-run custom recipes."
elsif ! File.exists?("/data/#{appname}/current/config/sitemap.rb")
  Chef::Log.info "SitemapGenerator was not configured because the app has no config/sitemap.rb file."
else
  rake_task = ping ? "sitemap:refresh" : "sitemap:refresh:no_ping"
  
  if utility_name
    install_here = (node[:name] == utility_name)
  else
    install_here = ['solo', 'app', 'app_master'].include?(node[:instance_role])
  end
  
  if install_here
    app_hosts = utility_name ? node[:members] : []
    
    run_for_app(appname) do |app_name, data|
      template "/usr/local/bin/sitemap-refresh" do
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
        source "sitemap-refresh.erb"
        variables({
          :app_name => app_name,
          :app_hosts => app_hosts,
          :instance_role => node[:instance_role],
          :rails_env => node[:environment][:framework_env],
          :rake_task => rake_task,
          :user => node[:owner_name]
        })
      end
      
      cron "sitemap_generator refresh" do
        action  :create
        minute  "#{cron_minute}"
        hour    "#{cron_hour}"
        day     '*'
        month   '*'
        weekday '*'
        command "/usr/local/bin/sitemap-refresh"
        user node[:owner_name]
      end
    end
  end
end
