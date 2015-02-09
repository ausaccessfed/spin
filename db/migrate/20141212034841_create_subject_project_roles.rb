class CreateSubjectProjectRoles < ActiveRecord::Migration
  def change
    create_table :subject_project_roles do |t|
      t.belongs_to :subject, index: true
      t.belongs_to :project_role, index: true
      t.timestamps
    end
  end
end
