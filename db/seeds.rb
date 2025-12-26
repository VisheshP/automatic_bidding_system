# Ceating Users

User.create!(
  full_name: "Seller User",
  email: "seller@gmail.com",
  role: "seller",
  password: "1234567",
  password_confirmation: "1234567"
)

User.create!(
  full_name: "Buyer User",
  email: "buyer@gmail.com",
  role: "buyer",
  password: "1234567",
  password_confirmation: "1234567"
)

User.create!(
  full_name: "Buyer II User",
  email: "buyer2@gmail.com",
  role: "buyer",
  password: "1234567",
  password_confirmation: "1234567"
)

# Creating Items

Item.create!(
  title: "Vintage Clock",
  description: "An antique wall clock from the 19th century.",
  starting_bid_price: 100,
  minimum_selling_price: 120,
  starting_bid_time: Time.now,
  ending_bid_time: Time.now + 7.days,
  user_id: User.find_by(email: "seller@gmail.com").id
)

Item.create!(
  title: "Modern Art Piece",
  description: "A beautiful modern art piece.",
  starting_bid_price: 200,
  minimum_selling_price: 220,
  starting_bid_time: Time.now,
  ending_bid_time: Time.now + 7.days,
  user_id: User.find_by(email: "seller@gmail.com").id
)

Item.create!(
  title: "Classic Novel",
  description: "A classic novel from the 19th century.",
  starting_bid_price: 50,
  minimum_selling_price: 60,
  starting_bid_time: Time.now,
  ending_bid_time: Time.now + 7.days,
  user_id: User.find_by(email: "seller@gmail.com").id
)
