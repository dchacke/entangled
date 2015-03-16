class DropMessages < ActiveRecord::Migration
  def self.up
    drop_table :messages
  end

  def self.down
    create_table "messages", force: :cascade do |t|
      t.text     "body"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
