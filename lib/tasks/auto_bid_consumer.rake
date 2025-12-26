# lib/tasks/auto_bid_consumer.rake
namespace :auto_bid do
  desc "Run the auto-bid stream consumer"
  task consume: :environment do
    consumer = AutoBidStreamConsumer.new
    consumer.run
  end
end
