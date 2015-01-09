FactoryGirl.define do
  factory :permission do
    association :role
    value '*'
  end
end
