FactoryBot.define do
  factory :item do
    title { "Vintage Item" }
    description { "Rare collectible" }
    starting_bid_price { 100 }
    minimum_selling_price { 150 }
    starting_bid_time { 1.day.from_now }
    ending_bid_time { 2.days.from_now }
    bidding_status { :upcoming }
    association :user
  end
end
