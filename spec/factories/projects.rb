FactoryGirl.define do
  factory :project do
    name { Faker::App.name }
    provider_arn do
      "arn:aws:iam::1:saml-provider/#{Faker::Lorem.characters(10)}"
    end
    active true
    association :organisation
  end
end
