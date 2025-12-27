class ApplicationController < ActionController::Base
  include SessionsHelper
  include UsersHelper

  before_action :check_expiry

  def check_expiry
    Item
      .where(bidding_status: Item.bidding_statuses["active"])
      .where(ending_bid_time: ...Time.current)
      .update_all(bidding_status: Item.bidding_statuses["expired"])
  end
end