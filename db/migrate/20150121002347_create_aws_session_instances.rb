class CreateAWSSessionInstances < ActiveRecord::Migration
  def change
    create_table :aws_session_instances do |t|
      t.belongs_to :subject, null: false
      t.belongs_to :project_role, null: false
      t.string :identifier, null: false
      t.timestamps
    end
  end
end
