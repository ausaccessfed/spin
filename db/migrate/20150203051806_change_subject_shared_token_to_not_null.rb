class ChangeSubjectSharedTokenToNotNull < ActiveRecord::Migration
  def change
    change_column_null(:subjects, :shared_token, false)
  end
end
