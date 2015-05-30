FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "user#{n}"}
    sequence(:firstname) { |n| "foo#{n}"}
    sequence(:lastname) { |n| "bar#{n}"}
    admin false
  end

end

