FactoryGirl.define do
  factory :project do |f|
    f.sequence(:name) { |n| "Redmine project #{n}" }
    f.sequence(:identifier) { |n| "project#{n}" }
  end
end