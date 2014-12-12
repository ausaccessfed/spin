class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.string :aws_identifier
      t.references :project, index: true

      t.timestamps
    end
  end
end
