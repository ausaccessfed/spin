class RenameProjectStatusToActive < ActiveRecord::Migration
  def change
    remove_column :projects, :state
    add_column :projects, :active, :boolean, default: true
  end
end
