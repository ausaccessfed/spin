class ChangeColumnsToNotNull < ActiveRecord::Migration
  def change
    change_column_null(:organisations, :name, false)
    change_column_null(:organisations, :external_id, false)

    change_column_null(:project_roles, :name, false)
    change_column_null(:project_roles, :aws_identifier, false)
    change_column_null(:project_roles, :project_id, false)

    change_column_null(:projects, :name, false)
    change_column_null(:projects, :aws_account, false)
    change_column_null(:projects, :state, false)
    change_column_null(:projects, :organisation_id, false)

    change_column_null(:subject_project_roles, :subject_id, false)
    change_column_null(:subject_project_roles, :project_role_id, false)

    change_column_null(:subject_roles, :subject_id, false)
    change_column_null(:subject_roles, :role_id, false)
  end
end
