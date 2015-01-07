class AddEnabledToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :enabled, :boolean, null: false, default: true
  end
end
