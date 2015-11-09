FactoryGirl.define do
  factory :movie do
    year 2000
    sequence(:title) { |n| "X-Men #{n}" }
    sequence(:tmdb_id) { |n| 1234 + n }
    times_said 0

    trait :popular do
      times_said 1000
    end

    trait :as_starting_movie do
      starting_movie true
    end
  end
end
