FactoryGirl.define do
  factory :organisation do
    name Faker::Name.name
    sequence(:external_id) { |n| "external_id_#{n}" }
  end
end
