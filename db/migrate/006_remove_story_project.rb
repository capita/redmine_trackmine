class RemoveStoryProject < ActiveRecord::Migration
  def self.up
    drop_table :story_projects
  end

  def self.down
    create_table :story_projects do |t|
      t.column :story_id, :integer
      t.column :tracker_project_id, :integer
      t.column :issue_id, :integer
    end
  end
end
