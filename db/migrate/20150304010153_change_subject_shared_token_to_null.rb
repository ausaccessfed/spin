class ChangeSubjectSharedTokenToNull < ActiveRecord::Migration
  def change
    change_column_null(:subjects, :shared_token, true)
  end
end
