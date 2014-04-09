# Set the name of your application.
# Leave blank to run on all applications.
default[:europeana_app_name] = "europeana19141918"

# Set the name of utility instance on which to run the Europeana purge job.
# Leave blank to install on all utility and solo instances.
default[:europeana_utility_name] = "utility"

# Set to false to disable the update cron job
default[:europeana_update] = true

# Set to false to disable the purge cron job
default[:europeana_purge] = true
