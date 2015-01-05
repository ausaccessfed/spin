class CreateSubjectSessions < ActiveRecord::Migration
  def change
    create_table :subject_sessions do |t|
      t.string :remote_host
      t.string :remote_addr, null: false
      t.string :http_user_agent
      t.belongs_to :subject, index: true

      t.timestamps
    end
  end
end
