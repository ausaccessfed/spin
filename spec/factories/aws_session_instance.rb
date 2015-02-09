FactoryGirl.define do
  factory :aws_session_instance do
    association :subject
    association :project_role
    identifier { SecureRandom.urlsafe_base64(30) }
  end
end
