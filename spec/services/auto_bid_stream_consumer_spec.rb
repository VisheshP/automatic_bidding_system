require "rails_helper"

RSpec.describe AutoBidStreamConsumer do
  let(:redis) { instance_double(Redis) }

  before do
    allow(Redis).to receive(:current).and_return(redis)

    allow(redis).to receive(:xgroup)
    allow(redis).to receive(:xreadgroup)
    allow(redis).to receive(:xack)
  end

  describe "#initialize" do
    it "creates redis consumer group" do
      expect(redis).to receive(:xgroup).with(
        :create,
        AutoBidStreamConsumer::STREAM_KEY,
        AutoBidStreamConsumer::GROUP_NAME,
        "$",
        mkstream: true
      )

      described_class.new
    end

    it "does not raise error if consumer group already exists" do
      allow(redis).to receive(:xgroup).and_raise(
        Redis::CommandError.new("BUSYGROUP Consumer Group name already exists")
      )

      expect { described_class.new }.not_to raise_error
    end
  end

  describe "#run / processing" do
    let(:consumer) { described_class.new }

    let(:entries) do
      [
        [
          AutoBidStreamConsumer::STREAM_KEY,
          [
            ["1680000000000-0", { "item_id" => "1", "amount" => "100" }]
          ]
        ]
      ]
    end
  end
end
