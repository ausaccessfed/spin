FactoryGirl.define do
  factory :role do
    name 'MyString'
    aws_identifier 'MyString'
    association :project
  end
end
