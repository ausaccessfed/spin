FactoryGirl.define do
  factory :role do
    name Faker::Name.name
    aws_identifier Faker::Lorem.characters(10)
    association :project
  end
end
