FactoryGirl.define do
  factory :project do
    name 'MyString'
    aws_account 'MyString'
    state 'MyString'
    association :organisation
  end
end
