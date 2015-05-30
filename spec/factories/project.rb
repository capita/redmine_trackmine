FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "Redmine project #{n}" }
    sequence(:identifier) { |n| "project#{n}"}
  end
end

