# Add arbitrary configuration values to apply to OpenSKOS's application.ini,
# within the section identified by the EY app framework env, e.g. "production"
#
default[:openskos_config] = {
  "resources.locale.default" => "en_GB.utf8",
  "phpSettings.display_startup_errors" => 1,
  "phpSettings.display_errors" => 1,
  "resources.frontController.params.displayExceptions" => 1
}

# Set the name of the Solr utility instance, if there is one.
# Leave blank to instruct OpenSKOS to connect to Solr on the localhost.
default[:solr_utility_name] = "solr"
