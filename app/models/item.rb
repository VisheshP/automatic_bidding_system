class Item < ApplicationRecord
  belongs_to :user
  has_many :bids, dependent: :destroy

  validates :description, :starting_bid_price, presence: true
  validates :title, presence: true, length: { in: 1..20 }

  validates :starting_bid_price, :minimum_selling_price, numericality: { greater_than: 0 }

  enum :bidding_status, { active: 0, expired: 1, upcoming: 2 }

  after_initialize :set_default_bidding_status, if: :new_record?
  before_validation :expiration_date_cannot_be_in_the_past, on: :create

  def set_default_bidding_status
    self.bidding_status = "upcoming" if self.starting_bid_time.present? && self.starting_bid_time > DateTime.current
  end

  def expiration_date_cannot_be_in_the_past
    if self.ending_bid_time.present? && ending_bid_time < DateTime.current
      errors.add(:ending_bid_time, "can't be in the past")
    end
  end

  def is_resumable?
    self.ending_bid_time < DateTime.current
  end
end