Factory.define :tracker_activity do |f|
  f.sequence(:name) {|n| "user#{n}"}
  f.sequence(:email) {|n| "user#{n}@zo.de"}
  f.password "password"
  f.password_confirmation { |u| u.password }
end
