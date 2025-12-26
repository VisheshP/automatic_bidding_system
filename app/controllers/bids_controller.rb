class BidsController < ApplicationController
  before_action :authenticate
  before_action :set_bid, only: %i[ edit update ]
  before_action :set_item, only: %i[new create edit update]
  before_action :authenticate_seller, only: %i[ index ]
  before_action :restrict_seller, only: %i[new create edit update]
  before_action :check_bidable, only: %i[new create edit update]
  

  def index
    @bids = Bid.all
  end

  def new
    @bid = @item.bids.build(bid_type: params[:bid_type] || "manual")
  end

  def edit
  end

  def create
    @bid = @item.bids.build(bid_params)
    @bid.user_id = current_user.id

    if @bid.save
      respond_to do |format|
        format.html { redirect_to items_path }
        format.turbo_stream { flash.now[:notice] = "Bid placed!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    bid_params.delete(:bid_type)
    @bid.assign_attributes(bid_params)
    if @bid.update(bid_params)
      respond_to do |format|
        format.html { redirect_to item_path(@bid.item) }
        format.turbo_stream { flash.now[:notice] = "Bid updated!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_bid
    @bid = Bid.find(params[:id])
  end

  def bid_params
    params.require(:bid).permit(:amount, :max_amount, :bid_type)
  end

  def check_bidable
    return if @item.active?

    flash[:alert] = "Bidding is closed / not opened for this item."
    redirect_to item_path(@item)
  end
end