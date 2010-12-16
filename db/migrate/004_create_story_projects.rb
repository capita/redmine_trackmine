class CreateStoryProjects < ActiveRecord::Migration
  def self.up
    create_table :story_projects do |t|
      t.column :story_id, :integer
      t.column :tracker_project_id, :integer
    end
  end

  def self.down
    drop_table :story_projects
  end
end
