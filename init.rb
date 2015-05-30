require 'redmine'
require 'pivotal_tracker'
require 'unicode'

Rails.logger.info 'Starting Trackmine Plugin for Redmine'

require_dependency 'project_patch'
require_dependency 'issue_patch'

Rails.application.config.middleware.insert_before(Rack::Runtime, 'PivotalHandler' )

Issue.send(:include, IssuePatch)
Project.send(:include, ProjectPatch)

Trackmine.set_error_notification

Redmine::Plugin.register :redmine_trackmine do
  name 'Redmine Trackmine plugin'
  author 'Piotr Brudny'
  description 'This plugin integrates Redmine projects with Pivotal Tracker'
  version '2.0.1'

  menu :admin_menu, :mapping, {controller: :mappings, action: 'index'}, caption: 'Trackmine', last: true
end
