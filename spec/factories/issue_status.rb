FactoryGirl.define do
  factory :issue_status do
    sequence(:name) { |n| "Status #{n}" }
  end
end

