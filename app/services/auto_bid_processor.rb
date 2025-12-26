
class AutoBidProcessor
  INCREMENT = 10

  def self.call(item_id:, current_amount:)
    lock_key = "lock:auto_bid:item:#{item_id}"

    # Acquire a short-lived lock to avoid race conditions.
    return unless Redis.current.set(lock_key, 1, nx: true, ex: 2)

    Item.transaction do
      highest = Bid.where(item_id: item_id).maximum(:amount) || 0
      current_amount = highest if highest > current_amount

      auto_bids = Bid.where(item_id: item_id, bid_type: "auto").where("max_amount > ?", current_amount).order(:created_at)

      return unless auto_bids.any?

      # Store the final bids each auto-bidder can place
      final_bids = []

      auto_bids.each do |bid|
        next_amount = [current_amount + INCREMENT, bid.max_amount].min
        # Only allow one increment per auto-bidder
        if next_amount > current_amount
          final_bids << { bidder: bid, amount: next_amount }
        end
      end

      # Find the highest final bid among auto-bidders
      winning_bid = final_bids.max_by { |b| b[:amount] }

      if winning_bid
        # Update the winning auto-bidder's bid
        winning_bid[:bidder].update!(amount: winning_bid[:amount])
      end
    end
  ensure
    Redis.current.del(lock_key)
  end
end
