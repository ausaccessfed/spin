FactoryBot.define do
  factory :subject_role do
    association :subject
    association :role
  end
end
