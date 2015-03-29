class CreateGrandmothers < ActiveRecord::Migration
  def change
    create_table :grandmothers do |t|

      t.timestamps null: false
    end
  end
end
