FactoryGirl.define do
  factory :user do
    name "bob"
    sequence(:username) { |n| "bob_#{n}" }
    password "hi"
  end
end
