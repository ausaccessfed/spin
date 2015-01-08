FactoryGirl.define do
  factory :api_subject_role do
    association :api_subject
    association :role
  end
end
