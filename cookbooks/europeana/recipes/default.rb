#
# Cookbook Name:: europeana
# Recipe:: default
#

# Configure in attributes/default.rb

node[:applications].each do |app_name, data|
  
  if node[:europeana_app_name].empty? || (node[:europeana_app_name] == app_name)

    if ! File.exists?("/data/#{app_name}/current")
      Chef::Log.info "europeana recipe was not configured because the app \"#{app_name}\" must be deployed first. Please deploy it then re-run custom recipes."
    elsif ! File.exists?("/data/#{app_name}/current/lib/tasks/europeana.rake")
      Chef::Log.info "europeana recipe was not configured because the app \"#{app_name}\" has no lib/tasks/europeana.rake file."
    else
      
      if (node[:europeana_utility_name].empty? && ['solo', 'util'].include?(node[:instance_role])) ||
        (!node[:europeana_utility_name].empty? && (node[:name] == node[:europeana_utility_name]))
        
        if node[:europeana_update]
          cron "europeana update" do
            action  :create
            minute  '45'
            hour    '4'
            day     '*'
            month   '*'
            weekday '6'
            command "cd /data/#{app_name}/current && bundle exec rake europeana:update"
            user node[:owner_name]
          end
        end
        
        if node[:europeana_purge]
          cron "europeana purge" do
            action  :create
            minute  '45'
            hour    '4'
            day     '*'
            month   '*'
            weekday '0'
            command "cd /data/#{app_name}/current && bundle exec rake europeana:purge"
            user node[:owner_name]
          end
        end
        
      end
    end
    
  end

end
