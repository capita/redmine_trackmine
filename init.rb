require 'redmine'
require 'dispatcher'
require 'pivotal_tracker'

RAILS_DEFAULT_LOGGER.info 'Starting Trackmine Plugin for Redmine'

# Patches to the Redmine core.
require_dependency 'project_patch'
require_dependency 'issue_patch'

Dispatcher.to_prepare do
  Issue.send(:include, IssuePatch)
  Project.send(:include, ProjectPatch)
end

Redmine::Plugin.register :redmine_trackmine do
  name 'Redmine Trackmine plugin'
  author 'Piotr Brudny'
  description 'This plugin integrates Redmine projects with Pivotal Tracker'
  version '0.0.1'
  
  menu :admin_menu, :mapping, { :controller => :mappings, :action => 'index' }, :caption =>'Trackmine', :last => true
end
