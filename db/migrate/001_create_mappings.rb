class CreateMappings < ActiveRecord::Migration
  def self.up
    create_table :mappings do |t|
      t.column :project_id, :integer
      t.column :tracker_project_id, :integer
      t.column :tracker_project_name, :text
      t.column :label, :text
    end
  end

  def self.down
    drop_table :mappings
  end
end
