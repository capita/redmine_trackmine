FactoryGirl.define do
  factory :tracker do
    sequence(:name) { |n| "Tracker #{n}" }
    default_status factory: :issue_status
  end
end

