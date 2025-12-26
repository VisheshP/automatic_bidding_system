require "rails_helper"

RSpec.describe Item, type: :model do
  let(:user) { create(:user) }

  subject do
    build(
      :item,
      user: user,
      title: "Antique Clock",
      description: "Very old clock",
      starting_bid_price: 100,
      minimum_selling_price: 150,
      starting_bid_time: 1.day.from_now,
      ending_bid_time: 2.days.from_now
    )
  end

  # -----------------------------
  # Associations
  # -----------------------------
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:bids).dependent(:destroy) }
  end

  # -----------------------------
  # Validations
  # -----------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:starting_bid_price) }

    it do
      is_expected.to validate_length_of(:title)
        .is_at_least(1)
        .is_at_most(20)
    end

    it do
      is_expected.to validate_numericality_of(:starting_bid_price)
        .is_greater_than(0)
    end

    it do
      is_expected.to validate_numericality_of(:minimum_selling_price)
        .is_greater_than(0)
    end
  end

  # -----------------------------
  # Enums
  # -----------------------------
  describe "enums" do
    it do
      is_expected.to define_enum_for(:bidding_status)
        .with_values(active: 0, expired: 1, upcoming: 2)
    end
  end

  # -----------------------------
  # Callbacks
  # -----------------------------
  describe "callbacks" do
    context "after_initialize" do
      it "sets bidding_status to upcoming if starting_bid_time is in future" do
        item = Item.new(
          user: user,
          starting_bid_time: 1.day.from_now
        )

        expect(item.bidding_status).to eq("upcoming")
      end
    end

    context "before_validation on create" do
      it "adds error if ending_bid_time is in the past" do
        item = build(
          :item,
          user: user,
          ending_bid_time: 1.day.ago
        )

        item.valid?

        expect(item.errors[:ending_bid_time])
          .to include("can't be in the past")
      end
    end
  end

  # -----------------------------
  # Instance Methods
  # -----------------------------
  describe "#is_resumable?" do
    context "when ending_bid_time is in the past" do
      it "returns true" do
        item = build(:item, ending_bid_time: 1.day.ago)
        expect(item.is_resumable?).to be true
      end
    end

    context "when ending_bid_time is in the future" do
      it "returns false" do
        item = build(:item, ending_bid_time: 1.day.from_now)
        expect(item.is_resumable?).to be false
      end
    end
  end
end
