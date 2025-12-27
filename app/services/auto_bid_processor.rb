class AutoBidProcessor
  INCREMENT = 10

  def self.call(item_id:, current_amount:)
    lock_key = "lock:auto_bid:item:#{item_id}"

    # Acquire a short-lived lock to avoid race conditions.
    return unless Redis.current.set(lock_key, 1, nx: true, ex: 2)

    Item.transaction do
      highest = Bid.where(item_id: item_id).maximum(:amount) || 0
      current_amount = highest if highest > current_amount

      auto_bids = Bid.where(item_id: item_id, bid_type: "auto")
                     .where("max_amount > ? and amount < ?", current_amount, current_amount)

      return unless auto_bids.any?

      Bid.where(item_id: item_id, bid_type: "auto")
         .where(amount: ...current_amount)
         .where(max_amount: current_amount..)
         .update_all(<<~SQL.squish)
           amount = LEAST(max_amount, #{current_amount + INCREMENT})
         SQL
    end
  ensure
    Redis.current.del(lock_key)
  end
end
