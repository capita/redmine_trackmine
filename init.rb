require 'redmine'
require 'pivotal_tracker'

# Adds relationship between Project and Mapping 
Project.class_eval do
  has_many :mappings
end

# Adds finding Issue by PivotalTracker ID
#Issue.class_eval do
#  def find_by_pivotal_id
#  end
#end

Redmine::Plugin.register :redmine_trackmine do
  name 'Redmine Trackmine plugin'
  author 'Piotr Brudny'
  description 'This plugin binds Redmine projects with Pivotal Tracker'
  version '0.0.1'
  
  menu :admin_menu, :mapping, { :controller => :mappings, :action => 'index' }, :caption =>'Trackmine', :last => true
end
