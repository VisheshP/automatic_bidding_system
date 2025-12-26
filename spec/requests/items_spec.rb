require "rails_helper"

RSpec.describe "ItemsController", type: :request do
  let(:seller) { create(:user, role: :seller) }
  let(:buyer)  { create(:user, role: :buyer) }
  let!(:item)  { create(:item, user: seller) }

  let(:valid_params) do
    {
      item: {
        title: "Vintage Clock",
        description: "Old antique clock",
        starting_bid_price: 100,
        minimum_selling_price: 150,
        starting_bid_time: 1.hour.from_now,
        ending_bid_time: 2.days.from_now
      }
    }
  end

  let(:invalid_params) do
    {
      item: {
        title: "",
        description: "",
        starting_bid_price: nil
      }
    }
  end

  # -----------------------------
  # INDEX
  # -----------------------------
  describe "GET /items" do
    xit "allows any authenticated user to view items" do
      sign_in(buyer)

      get items_path

      expect(response).to have_http_status(:ok)
    end
  end

  # -----------------------------
  # NEW
  # -----------------------------
  describe "GET /items/new" do
    it "allows seller to access new item page" do
      sign_in(seller)

      get new_item_path

      expect(response).to have_http_status(:ok)
    end
  end

  # -----------------------------
  # CREATE
  # -----------------------------
  describe "POST /items" do
    context "with valid params" do
      it "creates item and redirects" do
        sign_in(seller)

        expect {
          post items_path, params: valid_params
        }.to change(Item, :count).by(1)

        expect(response).to redirect_to(items_path)
      end
    end

    context "with invalid params" do
      it "does not create item" do
        sign_in(seller)

        expect {
          post items_path, params: invalid_params
        }.not_to change(Item, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # -----------------------------
  # EDIT
  # -----------------------------
  describe "GET /items/:id/edit" do
    it "allows seller to edit item" do
      sign_in(seller)

      get edit_item_path(item)

      expect(response).to have_http_status(:ok)
    end
  end

  # -----------------------------
  # UPDATE
  # -----------------------------
  describe "PATCH /items/:id" do
    context "when ending_bid_time is in the future" do
      it "sets bidding_status to active" do
        sign_in(seller)

        patch item_path(item),
              params: { item: { ending_bid_time: 3.days.from_now } }

        expect(item.reload.bidding_status).to eq("active")
        expect(response).to redirect_to(items_path)
      end
    end

    context "with invalid params" do
      it "does not update item" do
        sign_in(seller)

        patch item_path(item),
              params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # -----------------------------
  # DESTROY
  # -----------------------------
  describe "DELETE /items/:id" do
    it "deletes the item" do
      sign_in(seller)

      expect {
        delete item_path(item)
      }.to change(Item, :count).by(-1)

      expect(response).to redirect_to(items_path)
    end
  end

  # -----------------------------
  # AUTHORIZATION
  # -----------------------------
  describe "buyer restrictions" do
    it "prevents buyer from accessing new item page" do
      sign_in(buyer)

      get new_item_path

      expect(response).to have_http_status(:redirect)
    end
  end
end
