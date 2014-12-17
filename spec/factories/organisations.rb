FactoryGirl.define do
  factory :organisation do
    name Faker::Name.name
    external_id Faker::Lorem.characters(10)
  end
end
