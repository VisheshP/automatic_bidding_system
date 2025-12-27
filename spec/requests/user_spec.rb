require "rails_helper"

RSpec.describe "UsersController", type: :request do
  let(:seller) { create(:user, role: :seller) }
  let(:buyer)  { create(:user, role: :buyer) }

  let(:valid_params) do
    {
      user: {
        full_name: "Vishesh Purohit",
        email: "vishesh@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: "buyer"
      }
    }
  end

  let(:invalid_params) do
    {
      user: {
        full_name: "",
        email: "",
        password: "123",
        password_confirmation: "456"
      }
    }
  end

  # --------------------------------
  # GET /users/:id
  # --------------------------------
  describe "GET /users/:id" do
    it "requires authentication" do
      get user_path(seller)
      expect(response).to have_http_status(:redirect)
    end

    xit "shows user profile when authenticated" do
      sign_in(seller)

      get user_path(seller)

      expect(response).to have_http_status(:ok)
    end
  end

  # --------------------------------
  # GET /users/new
  # --------------------------------
  describe "GET /users/new" do
    it "renders signup page" do
      get register_path

      expect(response).to have_http_status(:ok)
    end
  end

  # --------------------------------
  # POST /users
  # --------------------------------
  describe "POST /users" do
    context "with valid params" do
      it "creates user, logs in, and redirects" do
        expect_any_instance_of(ApplicationController)
          .to receive(:login)

        expect do
          post users_path, params: valid_params
        end.to change(User, :count).by(1)

        expect(response).to redirect_to(items_path)
        expect(flash[:notice].downcase).to include("welcome, vishesh purohit!")
      end
    end

    context "with invalid params" do
      it "does not create user" do
        expect do
          post users_path, params: invalid_params
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # --------------------------------
  # GET /users/:id/edit
  # --------------------------------
  describe "GET /users/:id/edit" do
    xit "allows authenticated user to edit profile" do
      sign_in(seller)

      get edit_user_path(seller)

      expect(response).to have_http_status(:ok)
    end
  end

  # --------------------------------
  # PATCH /users/:id
  # --------------------------------
  describe "PATCH /users/:id" do
    context "with valid params" do
      it "updates user and redirects with notice" do
        sign_in(seller)

        patch user_path(seller), params: {
          user: { full_name: "Updated Name" }
        }

        expect(seller.reload.full_name.downcase).to eq("updated name")
        expect(response).to redirect_to(edit_user_path(seller))
        expect(flash[:notice]).to eq("Account updated!")
      end
    end

    context "with invalid params" do
      xit "does not update user" do
        sign_in(seller)

        patch user_path(seller), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # --------------------------------
  # DELETE /users/:id
  # --------------------------------
  describe "DELETE /users/:id" do
    it "deletes user and redirects" do
      sign_in(seller)

      expect do
        delete user_path(seller)
      end.to change(User, :count).by(-1)

      expect(response).to redirect_to(users_path)
      expect(flash[:notice]).to eq("Account deleted!")
    end
  end
end
