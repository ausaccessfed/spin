FactoryGirl.define do
  factory :project_role do
    name Faker::Name.name
    role_arn Faker::Lorem.characters(10)
    association :project
  end
end
