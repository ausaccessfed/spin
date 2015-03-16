class AddLastEmailSentAtToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :last_email_sent_at, :datetime, null: true
  end
end
