class CreateBars < ActiveRecord::Migration
  def change
    create_table :bars do |t|
      t.text :body

      t.timestamps null: false
    end
  end
end
