class StoryProject < ActiveRecord::Base
  unloadable
  validates_presence_of :story_id, :tracker_project_id
end
