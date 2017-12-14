FactoryBot.define do
  factory :subject_session do
    remote_host Faker::Internet.url
    remote_addr Faker::Internet.ip_v4_address
    http_user_agent Faker::Lorem.characters
    association :subject
  end
end
