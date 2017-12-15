FactoryBot.define do
  factory :subject_project_role do
    association :subject
    association :project_role
  end
end
