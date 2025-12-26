require "rails_helper"

RSpec.describe "BidsController", type: :request do
  let(:buyer)  { create(:user, role: :buyer) }
  let(:seller) { create(:user, role: :seller) }
  let(:item)   { create(:item, bidding_status: :active) }

  let(:valid_params) do
    {
      bid: {
        amount: 120,
        max_amount: 200,
        bid_type: "manual"
      }
    }
  end

  let(:invalid_params) do
    {
      bid: {
        amount: nil,
        max_amount: nil
      }
    }
  end

  # -----------------------------
  # INDEX
  # -----------------------------
  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(seller)
  end

  describe "GET /bids" do
    xit "allows seller to view all bids" do
      sign_in(seller)

      debugger
      
      get bids_path

      expect(response).to have_http_status(:ok)
    end
  end

  # -----------------------------
  # NEW
  # -----------------------------
  describe "GET /items/:item_id/bids/new" do
    it "allows buyer to access new bid form" do
      sign_in(buyer)

      get new_item_bid_path(item)

      expect(response).to have_http_status(:ok)
    end
  end

  # -----------------------------
  # CREATE
  # -----------------------------
  describe "POST /items/:item_id/bids" do
    context "with valid params" do
      it "creates a new bid" do
        sign_in(buyer)

        expect {
          post item_bids_path(item), params: valid_params
        }.to change(Bid, :count).by(1)

        expect(response).to redirect_to(items_path)
      end
    end

    context "with invalid params" do
      it "does not create bid and returns unprocessable entity" do
        sign_in(buyer)

        expect {
          post item_bids_path(item), params: invalid_params
        }.not_to change(Bid, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # -----------------------------
  # EDIT
  # -----------------------------
  describe "GET /items/:item_id/bids/:id/edit" do
    let(:bid) { create(:bid, item: item, user: buyer) }

    it "allows buyer to edit bid" do
      sign_in(buyer)

      get edit_item_bid_path(item, bid)

      expect(response).to have_http_status(:ok)
    end
  end

  # -----------------------------
  # UPDATE
  # -----------------------------
  describe "PATCH /items/:item_id/bids/:id" do
    let(:bid) { create(:bid, item: item, user: buyer) }

    context "with valid params" do
      it "updates the bid" do
        sign_in(buyer)

        patch item_bid_path(item, bid),
              params: { bid: { amount: 300 } }

        expect(bid.reload.amount).to eq(300)
      end
    end

    context "with invalid params" do
      it "does not update bid" do
        sign_in(buyer)

        patch item_bid_path(item, bid),
              params: { bid: { amount: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # -----------------------------
  # CHECK BIDABLE
  # -----------------------------
  describe "bidding closed" do
    let(:expired_item) { create(:item, bidding_status: :expired) }

    it "redirects when bidding is closed" do
      sign_in(buyer)

      get new_item_bid_path(expired_item)

      expect(response).to redirect_to(item_path(expired_item))
      follow_redirect!

      expect(flash[:alert])
          .to eq("Bidding is closed / not opened for this item.")
    end
  end
end
