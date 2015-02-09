class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :aws_account
      t.string :state
      t.belongs_to :organisation

      t.timestamps
    end
  end
end
