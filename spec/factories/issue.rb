FactoryGirl.define do
  factory :issue do
    project_id 1
    sequence(:subject) { |n| "Foo subject #{n}"}
    association :tracker
    author_id 1
    sequence(:description) { |n| "Factory description #{n}"}
  end
end

