class AddUniqueIndexs < ActiveRecord::Migration
  def change
    add_index :api_subject_roles, [:api_subject_id, :role_id],
              unique: true

    add_index :api_subjects, :x509_cn, unique: true

    add_index :permissions, [:role_id, :value], unique: true

    add_index :subject_roles, [:subject_id, :role_id], unique: true
    add_index :subject_project_roles, [:subject_id, :project_role_id],
              unique: true

    add_index :subjects, :mail, unique: true

    add_index :organisations, :external_id, unique: true
  end
end
