ey-cloud-recipes/sitemap_generator
==================================

This recipe simply creates a daily cron job to generate a sitemap for your
website on all solo and application instances, using the 
[SitemapGenerator](http://rubygems.org/gems/sitemap_generator) gem.

Dependencies
============

Your application should already be configured to use SitemapGenerator. See the
gem's [documentation](https://github.com/kjvarga/sitemap_generator) for details.

Configuration
=============

Edit the variables at the start of the file recipes/default.rb

Usage
=====

If configured to run on a utility instance, after each cron run, the generated 
sitemap file(s) will be copied over to all app instances.
