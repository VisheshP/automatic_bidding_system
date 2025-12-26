require "rails_helper"

RSpec.describe "SessionsController", type: :request do
  let(:user) do
    create(
      :user,
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  # --------------------------------
  # GET /login
  # --------------------------------
  describe "GET /login" do
    context "when user is not logged in" do
      it "renders login page" do
        get login_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is already logged in" do
      it "redirects to items page" do
        allow_any_instance_of(ApplicationController)
          .to receive(:user_logged_in?)
          .and_return(true)

        get login_path

        expect(response).to redirect_to(items_path)
      end
    end
  end

  # --------------------------------
  # POST /login
  # --------------------------------
  describe "POST /login" do
    context "with valid credentials" do
      it "logs in the user and redirects to items" do
        expect_any_instance_of(ApplicationController)
          .to receive(:login)
          .with(user)

        post login_path, params: {
          session: {
            email: "TEST@EXAMPLE.COM", # tests downcase
            password: "password123"
          }
        }

        expect(response).to redirect_to(items_path)
      end
    end

    context "with invalid password" do
      it "redirects back to login with alert" do
        post login_path, params: {
          session: {
            email: user.email,
            password: "wrongpassword"
          }
        }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Invalid email or password")
      end
    end

    context "with non-existing email" do
      it "redirects back to login with alert" do
        post login_path, params: {
          session: {
            email: "unknown@example.com",
            password: "password123"
          }
        }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Invalid email or password")
      end
    end
  end

  # --------------------------------
  # DELETE /logout
  # --------------------------------
  describe "DELETE /logout" do
    it "logs out user and redirects to home" do
      expect_any_instance_of(ApplicationController)
        .to receive(:log_out)

      delete logout_path

      expect(response).to redirect_to(root_path)
    end
  end
end
