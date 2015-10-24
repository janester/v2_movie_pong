FactoryGirl.define do
  factory :movie do
    title "X-Men"
    year 2000
    sequence(:tmdb_id) { |n| 1234 + n }
    times_said 0

    trait :popular do
      times_said 1000
    end
  end
end
