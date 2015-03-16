json.subject do
  json.id @subject.id
  json.name @subject.name
  json.mail @subject.mail
  json.shared_token @subject.shared_token
  json.complete @subject.complete
  json.created_at @subject.created_at
  json.updated_at @subject.updated_at
end

json.invitations @subject.outstanding_invitations do |invitation|
  json.invitation_url accept_invitations_url(identifier: invitation.identifier)
  json.invitation_created_at invitation.created_at
end
