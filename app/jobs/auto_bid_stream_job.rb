class AutoBidStreamJob < ApplicationJob
  queue_as :default

  STREAM   = "auction:bids"
  GROUP    = "auto_bid_group"
  CONSUMER = "consumer-#{Socket.gethostname}"

  def perform
    create_group_if_needed

    messages = Redis.current.xreadgroup(
      GROUP,
      CONSUMER,
      STREAM,
      ">",
      count: 5,
      block: 1000
    )

    return unless messages

    messages.each do |_, entries|
      entries.each do |entry_id, data|
        AutoBidProcessor.call(
          item_id: data["item_id"].to_i,
          current_amount: data["amount"].to_i
        )

        Redis.current.xack(STREAM, GROUP, entry_id)
      end
    end
  end

  private

  def create_group_if_needed
    Redis.current.xgroup(
      "CREATE",
      STREAM,
      GROUP,
      "$",
      mkstream: true
    )
  rescue Redis::CommandError
    # Consumer group already exists
  end
end
