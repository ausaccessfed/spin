FactoryBot.define do
  factory :invitation do
    association :subject
    identifier { SecureRandom.urlsafe_base64(19) }
    name { Faker::Name.name }
    mail { Faker::Internet.email(name) }
    expires { 1.year.from_now.to_s(:db) }
  end
end
