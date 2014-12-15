FactoryGirl.define do
  factory :project do
    name Faker::Name.name
    aws_account Faker::Lorem.characters(10)
    state Faker::Lorem.characters(10)
    association :organisation
  end
end
