class AddIssueIdToStoryProjects < ActiveRecord::Migration
  def self.up
    add_column :story_projects, :issue_id, :integer
  end

  def self.down
    remove_column :story_projects, :issue_id
  end
end
