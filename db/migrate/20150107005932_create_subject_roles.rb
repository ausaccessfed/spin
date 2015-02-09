class CreateSubjectRoles < ActiveRecord::Migration
  def change
    create_table :subject_roles do |t|
      t.references :subject, null: false, index: true
      t.references :role, null: false, index: true

      t.timestamps
    end
  end
end
