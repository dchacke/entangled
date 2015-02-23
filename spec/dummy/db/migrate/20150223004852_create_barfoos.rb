class CreateBarfoos < ActiveRecord::Migration
  def change
    create_table :barfoos do |t|
      t.text :body

      t.timestamps null: false
    end
  end
end
