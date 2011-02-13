class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :label, :null => false
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
