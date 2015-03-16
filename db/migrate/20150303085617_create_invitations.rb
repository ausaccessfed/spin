class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.belongs_to :subject, index: true, null: false
      t.string :identifier, null: false
      t.string :name, null: false
      t.string :mail, null: false
      t.boolean :used, null: false, default: false
      t.timestamp :expires, null: false

      t.timestamps
      t.index :identifier, unique: true
      t.index :mail, unique: true
    end
  end
end
