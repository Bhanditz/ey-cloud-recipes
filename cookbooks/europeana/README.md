ey-cloud-recipes/europeana
==========================

This recipe creates weekly cron jobs to:

* update harvested Europeana records updated on the portal, via DelayedJob.
* purge harvested Europeana records no longer on the portal, via DelayedJob.

Dependencies
============

Your application should already be configured to use DelayedJob.

Configuration
=============

Edit the variables in the file attributes/default.rb

