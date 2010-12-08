class AddEstimationsToMappings < ActiveRecord::Migration
  def self.up
    add_column :mappings, :estimations, :text
  end

  def self.down
    remove_column :mappings, :estimations
  end
end
