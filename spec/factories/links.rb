# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link do
    address         "www.google.com"
    description     "MyText"
    user_id         1
    user
  end
end
