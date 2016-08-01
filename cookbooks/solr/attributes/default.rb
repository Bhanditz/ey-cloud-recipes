# Set the version of Solr to install
default[:solr_version] = "4.10.0"

# Set the name of utility instance on which to run Solr.
# Leave blank to install on all utility and solo instances.
default[:solr_utility_name] = "solr4_m3"

# Set to true to configure Sunspot for Rails applications on this environment
default[:solr_sunspot] = true

# Set memory limit in MB
default[:solr_memory_limit] = 2048
