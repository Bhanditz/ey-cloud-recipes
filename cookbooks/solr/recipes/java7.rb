# Install Java 7
[ 
  { :name => "dev-java/icedtea-bin",  :version => "7.2.3.3-r1" },
  { :name => "virtual/jdk",           :version => "1.7.0" },
  { :name => "virtual/jre",           :version => "1.7.0" }
].each do |package|

  ey_cloud_report "package-install" do
    message "Installing #{package[:name]}-#{package[:version]}"
  end
  
  enable_package package[:name] do
    version package[:version]
  end
    
  package package[:name] do 
    version package[:version]
    action :install 
    not_if "equery list #{package[:name]}-#{package[:version]}"
  end
  
end

# Set system-wide Java
execute "Set the default Java VM for the system to IcedTea 1.7" do
  command "java-config -S icedtea-bin-7"
end
