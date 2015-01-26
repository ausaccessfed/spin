class RenameProjectRoleAwsIdentifierToProjectRoleArn < ActiveRecord::Migration
  def change
    rename_column :project_roles, :aws_identifier, :role_arn
  end
end
