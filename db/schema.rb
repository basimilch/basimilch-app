# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2016_06_04_171106) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", id: :serial, force: :cascade do |t|
    t.string "trackable_type"
    t.integer "trackable_id"
    t.string "owner_type"
    t.integer "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.integer "recipient_id"
    t.string "scope"
    t.string "visibility"
    t.string "severity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["created_at", "key"], name: "index_activities_on_created_at_and_key"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
  end

  create_table "depot_coordinators", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "depot_id"
    t.boolean "publish_email", default: true
    t.boolean "publish_tel_mobile", default: true
    t.datetime "canceled_at"
    t.string "canceled_reason"
    t.integer "canceled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canceled_by_id"], name: "index_depot_coordinators_on_canceled_by_id"
    t.index ["depot_id"], name: "index_depot_coordinators_on_depot_id"
    t.index ["user_id"], name: "index_depot_coordinators_on_user_id"
  end

  create_table "depots", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "postal_address"
    t.string "postal_address_supplement"
    t.string "postal_code"
    t.string "city"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.string "exact_map_coordinates"
    t.string "picture"
    t.text "directions"
    t.integer "delivery_day"
    t.integer "delivery_time"
    t.string "opening_hours"
    t.text "notes"
    t.datetime "canceled_at"
    t.string "canceled_reason"
    t.integer "canceled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canceled_by_id"], name: "index_depots_on_canceled_by_id"
  end

  create_table "job_signups", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "author_id"
    t.datetime "canceled_at"
    t.string "canceled_reason"
    t.integer "canceled_by_id"
    t.index ["author_id"], name: "index_job_signups_on_author_id"
    t.index ["canceled_by_id"], name: "index_job_signups_on_canceled_by_id"
    t.index ["job_id"], name: "index_job_signups_on_job_id"
    t.index ["user_id"], name: "index_job_signups_on_user_id"
  end

  create_table "job_types", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "place"
    t.string "address"
    t.integer "slots"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "canceled_at"
    t.string "canceled_reason"
    t.integer "canceled_by_id"
    t.index ["canceled_by_id"], name: "index_job_types_on_canceled_by_id"
    t.index ["user_id"], name: "index_job_types_on_user_id"
  end

  create_table "jobs", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string "place"
    t.string "address"
    t.integer "slots"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "job_type_id"
    t.text "notes"
    t.datetime "canceled_at"
    t.string "canceled_reason"
    t.integer "canceled_by_id"
    t.index ["canceled_by_id"], name: "index_jobs_on_canceled_by_id"
    t.index ["job_type_id"], name: "index_jobs_on_job_type_id"
    t.index ["start_at"], name: "index_jobs_on_start_at"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "product_options", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "picture"
    t.decimal "size", null: false
    t.string "size_unit", null: false
    t.decimal "equivalent_in_milk_liters", null: false
    t.datetime "canceled_at"
    t.string "canceled_reason"
    t.integer "canceled_by_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canceled_by_id"], name: "index_product_options_on_canceled_by_id"
  end

  create_table "share_certificates", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.date "sent_at"
    t.date "payed_at"
    t.date "returned_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "value_in_chf"
    t.index ["user_id"], name: "index_share_certificates_on_user_id"
  end

  create_table "subscriberships", id: :serial, force: :cascade do |t|
    t.integer "subscription_id"
    t.integer "user_id"
    t.datetime "canceled_at"
    t.string "canceled_reason"
    t.integer "canceled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canceled_by_id"], name: "index_subscriberships_on_canceled_by_id"
    t.index ["subscription_id"], name: "index_subscriberships_on_subscription_id"
    t.index ["user_id"], name: "index_subscriberships_on_user_id"
  end

  create_table "subscription_items", id: :serial, force: :cascade do |t|
    t.integer "subscription_id"
    t.integer "product_option_id"
    t.integer "quantity", default: 0, null: false
    t.date "valid_since", null: false
    t.date "valid_until"
    t.datetime "canceled_at"
    t.string "canceled_reason"
    t.integer "canceled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "depot_id"
    t.index ["canceled_by_id"], name: "index_subscription_items_on_canceled_by_id"
    t.index ["depot_id"], name: "index_subscription_items_on_depot_id"
    t.index ["product_option_id"], name: "index_subscription_items_on_product_option_id"
    t.index ["subscription_id"], name: "index_subscription_items_on_subscription_id"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.string "name", limit: 100
    t.integer "basic_units", default: 1, null: false
    t.integer "supplement_units", default: 0, null: false
    t.string "denormalized_items_list"
    t.string "denormalized_subscribers_list"
    t.text "notes"
    t.datetime "canceled_at"
    t.string "canceled_reason"
    t.integer "canceled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canceled_by_id"], name: "index_subscriptions_on_canceled_by_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.boolean "admin", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "postal_address"
    t.string "postal_code"
    t.string "city"
    t.string "country"
    t.string "tel_mobile"
    t.string "tel_home"
    t.string "tel_office"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.datetime "last_seen_at"
    t.datetime "remembered_since"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.datetime "activation_sent_at"
    t.float "latitude"
    t.float "longitude"
    t.datetime "last_login_at"
    t.string "last_login_from"
    t.string "postal_address_supplement"
    t.integer "seen_count", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.string "request_remote_ip"
    t.string "request_user_agent"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "depot_coordinators", "depots"
  add_foreign_key "depot_coordinators", "users"
  add_foreign_key "depot_coordinators", "users", column: "canceled_by_id"
  add_foreign_key "depots", "users", column: "canceled_by_id"
  add_foreign_key "job_signups", "jobs"
  add_foreign_key "job_signups", "users"
  add_foreign_key "job_signups", "users", column: "author_id"
  add_foreign_key "job_signups", "users", column: "canceled_by_id"
  add_foreign_key "job_types", "users"
  add_foreign_key "job_types", "users", column: "canceled_by_id"
  add_foreign_key "jobs", "job_types"
  add_foreign_key "jobs", "users"
  add_foreign_key "jobs", "users", column: "canceled_by_id"
  add_foreign_key "product_options", "users", column: "canceled_by_id"
  add_foreign_key "share_certificates", "users"
  add_foreign_key "subscriberships", "subscriptions"
  add_foreign_key "subscriberships", "users"
  add_foreign_key "subscriberships", "users", column: "canceled_by_id"
  add_foreign_key "subscription_items", "depots"
  add_foreign_key "subscription_items", "product_options"
  add_foreign_key "subscription_items", "subscriptions"
  add_foreign_key "subscription_items", "users", column: "canceled_by_id"
  add_foreign_key "subscriptions", "users", column: "canceled_by_id"
end
