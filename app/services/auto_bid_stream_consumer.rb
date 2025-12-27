class AutoBidStreamConsumer
  STREAM_KEY = "auction:bids".freeze
  GROUP_NAME = "auto_bid_group".freeze

  def initialize
    @consumer_name = "consumer-#{SecureRandom.uuid}"
    create_group
  end

  def run
    loop do
      entries = Redis.current.xreadgroup(
        GROUP_NAME, @consumer_name, STREAM_KEY, '>', block: 5000, count: 10
      )

      process_entries(entries) if entries
    end
  end

  private

  def create_group
    Redis.current.xgroup(:create, STREAM_KEY, GROUP_NAME, '$', mkstream: true)
  rescue Redis::CommandError => e
    raise e unless e.message.include?('BUSYGROUP Consumer Group name already exists')
  end

  def process_entries(entries)
    entries.each_value do |messages|
      messages.each do |message_id, data|
        item_id = data['item_id']
        current_amount = data['amount'].to_i

        # Call your processor here
        AutoBidProcessor.call(item_id: item_id, current_amount: current_amount)
        # Acknowledge the message
        Redis.current.xack(STREAM_KEY, GROUP_NAME, message_id)
      end
    end
  end
end
