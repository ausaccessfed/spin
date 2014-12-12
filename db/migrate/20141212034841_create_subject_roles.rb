class CreateSubjectRoles < ActiveRecord::Migration
  def change
    create_table :subject_roles, id: false do |t|
      t.belongs_to :subject, index: true
      t.belongs_to :role, index: true
    end
  end
end
