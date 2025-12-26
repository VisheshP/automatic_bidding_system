# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_12_22_182531) do
  create_table "bids", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "max_amount", default: 0, null: false
    t.integer "bid_type", default: 0, null: false
    t.integer "user_id", null: false
    t.integer "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_bids_on_item_id"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.integer "starting_bid_price", null: false
    t.integer "minimum_selling_price", null: false
    t.datetime "starting_bid_time", null: false
    t.datetime "ending_bid_time", null: false
    t.integer "bidding_status", default: 0, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bids", "items"
  add_foreign_key "bids", "users"
  add_foreign_key "items", "users"
end
