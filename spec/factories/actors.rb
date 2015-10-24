FactoryGirl.define do
  factory :actor do
    name "Hugh Jackman"
    sequence(:tmdb_id) { |n| 4567 + n }
    times_said 0

    trait :popular do
      times_said 1000
    end
  end
end
