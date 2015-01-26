FactoryGirl.define do
  factory :project_role do
    name Faker::Name.name
    association :project
    role_arn "arn:aws:iam::1:role/#{Faker::Lorem.characters(10)}"
  end
end
