FactoryGirl.define do
  factory :issue do
    project_id 1
    sequence(:subject) { |n| "Foo subject #{n}"}
    author_id 1
    sequence(:description) { |n| "Factory description #{n}"}
    priority_id 5
    tracker_id 1
  end
end

