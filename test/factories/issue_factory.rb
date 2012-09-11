FactoryGirl.define do
  factory :issue do |f|
    f.project_id 1
    f.sequence(:subject) { |n| "Foo subject #{n}" }
    f.tracker_id 1
    f.author_id 1
    f.sequence(:description) { |n| "FactoryGirl description #{n}" }
  end
end
