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

ActiveRecord::Schema[7.1].define(version: 2026_02_22_151524) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "subject"
    t.text "message"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.decimal "discount"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
  end

  create_table "receipts", force: :cascade do |t|
    t.string "receipt_no", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "used", default: false, null: false
    t.index ["receipt_no"], name: "index_receipts_on_receipt_no", unique: true
  end

  create_table "reward_application_items", force: :cascade do |t|
    t.integer "reward_application_id", null: false
    t.integer "product_id", null: false
    t.decimal "price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 1
    t.index ["product_id"], name: "index_reward_application_items_on_product_id"
    t.index ["reward_application_id"], name: "index_reward_application_items_on_reward_application_id"
  end

  create_table "reward_applications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "receipt_no"
    t.decimal "receipt_amount", precision: 10, scale: 2, default: "0.0"
    t.integer "points_to_earn", default: 0
    t.boolean "auto_approved", default: false
    t.boolean "auto_rejected", default: false
    t.string "rejection_reason"
    t.datetime "processed_at"
    t.index ["receipt_no"], name: "index_reward_applications_on_receipt_no"
    t.index ["user_id"], name: "index_reward_applications_on_user_id"
  end

  create_table "slider_images", force: :cascade do |t|
    t.string "image_url", null: false
    t.string "title"
    t.integer "position", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.string "phone_number"
    t.string "address"
    t.integer "reward_points", default: 100
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  add_foreign_key "feedbacks", "users"
  add_foreign_key "product_images", "products"
  add_foreign_key "reward_application_items", "products"
  add_foreign_key "reward_application_items", "reward_applications"
  add_foreign_key "reward_applications", "users"
end
