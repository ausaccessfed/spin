FactoryGirl.define do
  factory :subject do
    name { Faker::Name.name }
    mail { Faker::Internet.email(name) }
    shared_token { SecureRandom.urlsafe_base64(16) }
    targeted_id do
      "https://rapid.example.com!https://ide.example.com!#{SecureRandom.hex}"
    end

    trait :authorized do

      after(:create) do |subject|
        role = create(:role)
        create(:subject_role, role: role, subject: subject)
      end
    end

  end
end
