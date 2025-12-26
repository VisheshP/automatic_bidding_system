class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :amount, presence: true
  after_commit :publish_bid_event, on: [:create, :update]

  scope :bid_winner, ->() { find_by(amount: self.maximum(:amount)) }

  enum :bid_type, { manual: 0, auto: 1 }

  def self.bid_winner_text
    bid = bid_winner
    if bid.present?
      bid.amount > bid.item.minimum_selling_price ? "Winner: #{bid.user.full_name} 🎉" : "No one bided above minimum selling price"
    end
  end

  private

  def publish_bid_event
    Redis.current.xadd(
      "auction:bids",
      {
        item_id: item_id,
        amount: amount,
        user_id: user_id
      }
    )
  end
end