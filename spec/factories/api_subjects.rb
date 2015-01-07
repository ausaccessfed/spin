FactoryGirl.define do
  factory :api_subject do
    x509_cn { SecureRandom.urlsafe_base64 }
    description { Faker::Company.bs }
    contact_name { Faker::Name.name }
    contact_mail { Faker::Internet.email(contact_name) }

    trait :authorized do
      transient { permission '*' }

      after(:create) do |api_subject, attrs|
        perm = create(:permission, value: attrs.permission)
        create(:api_subject_role, role: perm.role, api_subject: api_subject)
      end
    end
  end

end
