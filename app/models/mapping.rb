class Mapping < ActiveRecord::Base
  unloadable

  attr_accessible :project_id, :label, :estimations, :story_types, :tracker_project_id

  belongs_to :project

  validates :project_id, presence:true
  validates :tracker_project_id, presence:true
  validates :estimations, presence:true
  validates :story_types, presence:true

  validates_uniqueness_of :tracker_project_id, scope: :label

  serialize :estimations
  serialize :story_types
end
