Factory.define :mapping do |f|
  f.project_id 1
  f.sequence(:tracker_project_id) {|n| n}
  f.sequence(:tracker_project_name) {|n| "Foo tracker project #{n}"}
  f.sequence(:label){|n| "foolabel#{n}"}
end
