FactoryBot.define do
  factory :organisation do
    name { Faker::Company.name }
    sequence(:unique_identifier) { |n| "unique_identifier_#{n}" }
  end
end
