class AddStoryTypesToMappings < ActiveRecord::Migration
  def self.up
    add_column :mappings, :story_types, :text
  end

  def self.down
    remove_column :mappings, :story_types
  end
end
