FactoryGirl.define do
  factory :organisation do
    name Faker::Name.name
    sequence(:unique_identifier) { |n| "unique_identifier_#{n}" }
  end
end
