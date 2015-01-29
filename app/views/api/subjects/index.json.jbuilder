json.subjects @subjects do |subject|
  json.id subject.id
  json.shared_token subject.shared_token
  json.mail subject.mail
  json.name subject.name
end
