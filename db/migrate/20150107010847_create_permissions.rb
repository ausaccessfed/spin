class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.references :role, null: false, index: true
      t.string :value, null: false

      t.timestamps
    end
  end
end
