Factory.define :mapping do |f|
  f.project_id 1
  f.sequence(:tracker_project_id) {|n| n}
  f.sequence(:tracker_project_name) {|n| "Foo tracker project #{n}"}
  f.sequence(:label){|n| "foolabel#{n}"}
  f.estimations {|e| e = { '1' => '1', '2' => '4', '3' => '10' } }
  f.story_types {|st| st = { 'feature' => 'Feature', 'bug' => 'Bug', 'chore' => 'Support' } }
end
