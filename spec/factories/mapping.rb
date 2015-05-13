FactoryGirl.define do
  factory :mapping do
    association :project
    sequence(:tracker_project_id) { |n| n}
    sequence(:tracker_project_name) { |n| "Foo tracker project #{n}"}
    sequence(:label){|n| "foolabel#{n}"}
    estimations { |e| e = { '1' => '1', '2' => '4', '3' => '10' } }
    story_types { |st| st = { 'feature' => 'Feature', 'bug' => 'Bug', 'chore' => 'Support' } }
  end
end

