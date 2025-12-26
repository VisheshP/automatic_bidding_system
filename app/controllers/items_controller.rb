class ItemsController < ApplicationController
  before_action :authenticate
  before_action :set_item, only: %i[ show edit update destroy ]
  before_action :authenticate_seller, except: %i[index]
  

  def index
    @items = Item.order(created_at: :desc)
  end

  def new
    @item = current_user.items.build
  end

  def edit
  end

  def create
    @item = current_user.items.build(item_params)

    if @item.save
      respond_to do |format|
        format.html { redirect_to items_path }
        format.turbo_stream { flash.now[:notice] = "Item added!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if item_params[:ending_bid_time] && item_params[:ending_bid_time].to_datetime.future?
      @item.bidding_status = "active"
    end
    if @item.update(item_params)
      respond_to do |format|
        format.html { redirect_to items_path }
        format.turbo_stream { flash.now[:notice] = "Item updated!" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_path }
      format.turbo_stream { flash.now[:notice] = "Item deleted!" }
    end
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :description, :starting_bid_price, :minimum_selling_price, :starting_bid_time, 
                                 :ending_bid_time, :bidding_status)
  end
end