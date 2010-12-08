class Mapping < ActiveRecord::Base
  unloadable

  belongs_to :project
  validates_presence_of :project_id, :tracker_project_id, :estimations, :story_types
  validates_uniqueness_of :tracker_project_id, :scope => :label
  serialize :estimations
  serialize :story_types
end
