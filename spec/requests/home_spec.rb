require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /" do
    it "renders the home page successfully" do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
