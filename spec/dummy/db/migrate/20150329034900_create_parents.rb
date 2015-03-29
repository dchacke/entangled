class CreateParents < ActiveRecord::Migration
  def change
    create_table :parents do |t|
      t.integer :grandmother_id
      t.integer :grandfather_id

      t.timestamps null: false
    end
  end
end
