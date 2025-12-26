class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :starting_bid_price, null: false
      t.integer :minimum_selling_price, null: false
      t.datetime :starting_bid_time, null: false
      t.datetime :ending_bid_time, null: false
      t.integer :bidding_status, default: 0, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
