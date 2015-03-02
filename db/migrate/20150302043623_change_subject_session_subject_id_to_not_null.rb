class ChangeSubjectSessionSubjectIdToNotNull < ActiveRecord::Migration
  def change
    change_column_null(:subject_sessions, :subject_id, false)
  end
end
