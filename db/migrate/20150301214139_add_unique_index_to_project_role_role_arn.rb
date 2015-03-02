class AddUniqueIndexToProjectRoleRoleARN < ActiveRecord::Migration
  def change
    add_index :project_roles, :role_arn, unique: true
  end
end
