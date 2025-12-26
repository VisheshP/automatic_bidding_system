require "rails_helper"

RSpec.describe Bid, type: :model do
  let(:user) { create(:user, full_name: "Vishesh Purohit") }
  let(:item) { create(:item, minimum_selling_price: 100, starting_bid_price: 50, starting_bid_time: Time.current, ending_bid_time: Time.current + 1.hour, bidding_status: :active, user: user) }

  subject do
    build(
      :bid,
      user: user,
      item: item,
      amount: 120,
      max_amount: 200,
      bid_type: :manual
    )
  end

  # -----------------------------
  # Associations
  # -----------------------------
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:item) }
  end

  # -----------------------------
  # Validations
  # -----------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:amount) }
  end

  # -----------------------------
  # Enums
  # -----------------------------
  describe "enums" do
    it do
      is_expected.to define_enum_for(:bid_type)
        .with_values(manual: 0, auto: 1)
    end
  end

  # -----------------------------
  # Callbacks
  # -----------------------------
  describe "callbacks" do
    let(:redis) { instance_double(Redis) }

    before do
      allow(Redis).to receive(:current).and_return(redis)
      allow(redis).to receive(:xadd)
    end

    it "publishes bid event to Redis after create" do
      bid = create(:bid, user: user, item: item, amount: 150, max_amount: 300)

      expect(redis).to have_received(:xadd).with(
        "auction:bids",
        hash_including(
          item_id: bid.item_id,
          amount: bid.amount,
          user_id: bid.user_id
        )
      )
    end
  end

  # -----------------------------
  # Scopes
  # -----------------------------
  describe "scopes" do
    let!(:high_bid) { create(:bid, item: item, amount: 200, max_amount: 300) }

    describe ".bid_winner" do
      it "returns bid with highest amount" do
        expect(described_class.bid_winner).to eq(high_bid)
      end
    end
  end

  # -----------------------------
  # Class Methods
  # -----------------------------
  describe ".bid_winner_text" do
    context "when highest bid meets minimum selling price" do
      before do
        create(:bid, user: user, item: item, amount: 150, max_amount: 200)
      end

      it "returns winner text with user name" do
        expect(described_class.bid_winner_text.downcase)
          .to include("vishesh purohit")
      end
    end

    context "when no bid meets minimum selling price" do
      before do
        create(:bid, user: user, item: item, amount: 80, max_amount: 100)
      end

      it "returns failure message" do
        expect(described_class.bid_winner_text)
          .to eq("No one bided above minimum selling price")
      end
    end
  end
end
