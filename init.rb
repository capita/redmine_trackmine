require 'redmine'
require 'pivotal_tracker'


Redmine::Plugin.register :redmine_trackmine do
  name 'Redmine Trackmine plugin'
  author 'Piotr Brudny'
  description 'This plugin binds Redmine projects with Pivotal Tracker'
  version '0.0.1'
  
  menu :admin_menu, :mapping, { :controller => :mappings, :action => 'index' }, :caption =>'Trackmine', :last => true
end
