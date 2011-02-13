class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :title, :url, :null => false
      t.string :author_name, :author_url, :thumbnail_url
      t.integer :width, :height, :null => false
      t.integer :thumbnail_width, :thumbnail_height
      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
