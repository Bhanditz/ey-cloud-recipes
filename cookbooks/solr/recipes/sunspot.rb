if [ 'app', 'app_master', 'solo', 'util' ].include?(node[:instance_role])
  
  node[:applications].each do |app_name, data|
    
    app_dir = "/data/#{app_name}/current"
    solr_hostname = if node[:solr_utility_name].empty?
      "localhost"
    else
      if solr_utility = node[:utility_instances].find { |utility| utility[:name] == node[:solr_utility_name] }
        solr_utility[:hostname]
      else
        Chef::Log.info "Sunspot was not configured because no there is no utility instance named #{node[:solr_utility_name]}"
        nil
      end
    end
    
    unless solr_hostname.nil?
      template "/data/#{app_name}/shared/config/sunspot.yml" do
        source "sunspot.yml.erb"
        owner node[:owner_name]
        group node[:owner_name]
        mode 0644
        variables({
          :rails_env => node[:environment][:framework_env],
          :solr_hostname => solr_hostname,
          :application => app_name
        })
      end
    end
  end
  
end
