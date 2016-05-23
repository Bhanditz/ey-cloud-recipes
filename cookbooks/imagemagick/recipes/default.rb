username = node[:users].first[:username]
config_dir = "/home/#{username}/.magick"

directory config_dir do
  owner username
  group username
  recursive true
end

remote_file "#{config_dir}/policy.xml" do
  source 'policy.xml'
  owner username
  group username
  mode 0644
end
