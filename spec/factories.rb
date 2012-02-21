FactoryGirl.define do
  factory :user do
    sequence(:name)  { |nn| "User_#{nn}" }
    sequence(:email) { | nn| "user_#{nn}@example.org" }
  end

  factory :project do
    sequence(:name)  { |nn| "Project_#{nn}" }
    user
    amount 1234.56
    funding_due Time.now + 2.weeks
  end

  factory :contribution do
    user
    project
    amount "29.95"
  end
end
