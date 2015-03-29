class CreateGrandfathers < ActiveRecord::Migration
  def change
    create_table :grandfathers do |t|

      t.timestamps null: false
    end
  end
end
