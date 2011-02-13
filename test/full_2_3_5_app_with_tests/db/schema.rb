# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110212022722) do

  create_table "items", :force => true do |t|
    t.string   "label",       :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.string   "title",            :null => false
    t.string   "url",              :null => false
    t.string   "author_name"
    t.string   "author_url"
    t.string   "thumbnail_url"
    t.integer  "width",            :null => false
    t.integer  "height",           :null => false
    t.integer  "thumbnail_width"
    t.integer  "thumbnail_height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
