FactoryBot.define do
  factory :bid do
    amount { 120 }
    max_amount { 200 }
    bid_type { :manual }
    association :user
    association :item
  end
end
