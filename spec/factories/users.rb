FactoryBot.define do
  factory :user do
    full_name { "Vishesh Purohit" }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { :buyer }
  end
end
