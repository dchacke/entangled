class CreateFoobars < ActiveRecord::Migration
  def change
    create_table :foobars do |t|
      t.text :body

      t.timestamps null: false
    end
  end
end
