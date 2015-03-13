class RemoveSubjectUniqueMailIndex < ActiveRecord::Migration
  def change
    remove_index :subjects, name: 'index_subjects_on_mail'
  end
end
