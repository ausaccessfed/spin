FactoryGirl.define do
  factory :project do
    name Faker::Name.name
    provider_arn "arn:aws:iam::1:saml-provider/#{Faker::Lorem.characters(10)}"
    active true
    association :organisation
  end
end
