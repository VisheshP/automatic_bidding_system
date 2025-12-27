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

        expect do
          described_class.call(item_id: item.id, current_amount: 100)
        end.not_to change(Bid, :count)
      end
    end

    context "when highest bid already exceeds current amount" do
      it "returns early without updating bids" do
        create(:bid, item: item, amount: 200)

        expect do
          described_class.call(item_id: item.id, current_amount: 100)
        end.not_to(change { Bid.maximum(:amount) })
      end
    end

    context "when no auto bids exist" do
      it "does nothing" do
        create(:bid, item: item, bid_type: :manual, amount: 50)

        expect do
          described_class.call(item_id: item.id, current_amount: 50)
        end.not_to(change { Bid.maximum(:amount) })
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
    end

    context "redis cleanup" do
      it "always releases redis lock" do
        described_class.call(item_id: item.id, current_amount: 50)

        expect(redis).to have_received(:del)
      end
    end
  end
end
