#
# Cookbook Name:: dir_sync
# Recipe:: default
#

# Set the name of the utility instance containing the directory to monitor
utility_name = "utility"

# Set the directory to keep in sync
directory = "/data/europeana19141918/shared/exports"


if node[:name] == utility_name

  template "/usr/local/bin/dir-sync" do
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
    source "dir-sync.erb"
    variables({
      :app_hosts => node[:members],
      :directory => directory,
      :user => node[:owner_name]
    })
  end

  cron "dir_sync" do
    action  :create
    minute  '*'
    hour    '*'
    day     '*'
    month   '*'
    weekday '*'
    command '/usr/local/bin/dir-sync'
    user node[:owner_name]
  end

end

