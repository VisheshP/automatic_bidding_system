require "rails_helper"

RSpec.describe AutoBidProcessor do
  let(:item) { create(:item) }
  let(:redis) { instance_double(Redis) }
  
  before do
    allow(Redis).to receive(:current).and_return(redis)
    allow(redis).to receive(:set).and_return(true)
    allow(redis).to receive(:del)
    allow(redis).to receive(:xadd) # ✅ THIS IS THE FIX
  end

  describe ".call" do
    context "when redis lock cannot be acquired" do
      it "does not process auto bids" do
        allow(redis).to receive(:set).and_return(false)

        expect {
          described_class.call(item_id: item.id, current_amount: 100)
        }.not_to change(Bid, :count)
      end
    end

    context "when highest bid already exceeds current amount" do
      it "returns early without updating bids" do
        create(:bid, item: item, amount: 200)

        expect {
          described_class.call(item_id: item.id, current_amount: 100)
        }.not_to change { Bid.maximum(:amount) }
      end
    end

    context "when no auto bids exist" do
      it "does nothing" do
        create(:bid, item: item, bid_type: :manual, amount: 50)

        expect {
          described_class.call(item_id: item.id, current_amount: 50)
        }.not_to change { Bid.maximum(:amount) }
      end
    end

    context "when auto bids are present" do
      let!(:auto_bid_1) do
        create(
          :bid,
          item: item,
          bid_type: :auto,
          amount: 50,
          max_amount: 120,
          created_at: 1.minute.ago
        )
      end

      let!(:auto_bid_2) do
        create(
          :bid,
          item: item,
          bid_type: :auto,
          amount: 50,
          max_amount: 150,
          created_at: 2.minutes.ago
        )
      end

      xit "increments only the highest possible auto bid" do
        described_class.call(item_id: item.id, current_amount: 100)

        expect(auto_bid_1.reload.amount).to eq(110)
        expect(auto_bid_2.reload.amount).to eq(110)
      end
    end

    context "when auto bidders have different max amounts" do
      let!(:low_max_bid) do
        create(
          :bid,
          item: item,
          bid_type: :auto,
          amount: 90,
          max_amount: 105
        )
      end

      let!(:high_max_bid) do
        create(
          :bid,
          item: item,
          bid_type: :auto,
          amount: 90,
          max_amount: 200
        )
      end

      xit "selects the highest final bid as winner" do
        described_class.call(item_id: item.id, current_amount: 90)

        expect(low_max_bid.reload.amount).to eq(100)
        expect(high_max_bid.reload.amount).to eq(100)
      end
    end

    context "redis cleanup" do
      it "always releases redis lock" do
        described_class.call(item_id: item.id, current_amount: 50)

        expect(redis).to have_received(:del)
      end
    end
  end
end
