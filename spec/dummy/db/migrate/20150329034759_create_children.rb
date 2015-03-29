class CreateChildren < ActiveRecord::Migration
  def change
    create_table :children do |t|
      t.integer :parent_id

      t.timestamps null: false
    end
  end
end
