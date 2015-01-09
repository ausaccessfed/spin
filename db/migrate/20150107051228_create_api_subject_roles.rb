class CreateAPISubjectRoles < ActiveRecord::Migration
  def change
    create_table :api_subject_roles do |t|
      t.references :api_subject, null: false, index: true
      t.references :role, null: false, index: true

      t.timestamps
    end
  end
end
