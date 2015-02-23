class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body

      t.timestamps null: false
    end
  end
end
