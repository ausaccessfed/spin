FactoryGirl.define do
  factory :project_role do
    name Faker::Name.name
    aws_identifier Faker::Lorem.characters(10)
    association :project
  end
end
