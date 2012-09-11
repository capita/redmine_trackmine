require 'redmine'
require 'bundler'
Bundler.setup(:default)
require 'pivotal_tracker'
require 'unicode'

Rails.logger.info 'Starting Trackmine Plugin for Redmine'

# Patches to the Redmine core.
require_dependency 'project_patch'
require_dependency 'issue_patch'

Rails.configuration.to_prepare do
  Rails.configuration.middleware.insert_after OpenIdAuthentication, "PivotalHandler"
  Issue.send(:include, IssuePatch)
  Project.send(:include, ProjectPatch)
end

# Sets error email for trackmine mailer
Trackmine.set_error_notification

Redmine::Plugin.register :redmine_trackmine do
  name 'Redmine Trackmine plugin'
  author 'Piotr Brudny'
  description 'This plugin integrates Redmine projects with Pivotal Tracker'
  version '1.0.1-redmine_2'
  
  menu :admin_menu, :mappings, { :controller => :mappings, :action => 'index' }, :caption =>'Trackmine', :last => true
end
