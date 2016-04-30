# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160429175436) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.string   "scope"
    t.string   "visibility"
    t.string   "severity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["created_at", "key"], name: "index_activities_on_created_at_and_key", using: :btree
  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "depot_coordinators", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "depot_id"
    t.boolean  "publish_email",      default: true
    t.boolean  "publish_tel_mobile", default: true
    t.datetime "canceled_at"
    t.string   "canceled_reason"
    t.integer  "canceled_by_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "depot_coordinators", ["canceled_by_id"], name: "index_depot_coordinators_on_canceled_by_id", using: :btree
  add_index "depot_coordinators", ["depot_id"], name: "index_depot_coordinators_on_depot_id", using: :btree
  add_index "depot_coordinators", ["user_id"], name: "index_depot_coordinators_on_user_id", using: :btree

  create_table "depots", force: :cascade do |t|
    t.string   "name"
    t.string   "postal_address"
    t.string   "postal_address_supplement"
    t.string   "postal_code"
    t.string   "city"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "exact_map_coordinates"
    t.string   "picture"
    t.text     "directions"
    t.integer  "delivery_day"
    t.integer  "delivery_time"
    t.string   "opening_hours"
    t.text     "notes"
    t.datetime "canceled_at"
    t.string   "canceled_reason"
    t.integer  "canceled_by_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "depots", ["canceled_by_id"], name: "index_depots_on_canceled_by_id", using: :btree

  create_table "job_signups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "author_id"
    t.datetime "canceled_at"
    t.string   "canceled_reason"
    t.integer  "canceled_by_id"
  end

  add_index "job_signups", ["author_id"], name: "index_job_signups_on_author_id", using: :btree
  add_index "job_signups", ["canceled_by_id"], name: "index_job_signups_on_canceled_by_id", using: :btree
  add_index "job_signups", ["job_id"], name: "index_job_signups_on_job_id", using: :btree
  add_index "job_signups", ["user_id"], name: "index_job_signups_on_user_id", using: :btree

  create_table "job_types", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "place"
    t.string   "address"
    t.integer  "slots"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "canceled_at"
    t.string   "canceled_reason"
    t.integer  "canceled_by_id"
  end

  add_index "job_types", ["canceled_by_id"], name: "index_job_types_on_canceled_by_id", using: :btree
  add_index "job_types", ["user_id"], name: "index_job_types_on_user_id", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "place"
    t.string   "address"
    t.integer  "slots"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "job_type_id"
    t.text     "notes"
    t.datetime "canceled_at"
    t.string   "canceled_reason"
    t.integer  "canceled_by_id"
  end

  add_index "jobs", ["canceled_by_id"], name: "index_jobs_on_canceled_by_id", using: :btree
  add_index "jobs", ["job_type_id"], name: "index_jobs_on_job_type_id", using: :btree
  add_index "jobs", ["start_at"], name: "index_jobs_on_start_at", using: :btree
  add_index "jobs", ["user_id"], name: "index_jobs_on_user_id", using: :btree

  create_table "product_options", force: :cascade do |t|
    t.string   "name",                      null: false
    t.text     "description"
    t.string   "picture"
    t.decimal  "size",                      null: false
    t.string   "size_unit",                 null: false
    t.decimal  "equivalent_in_milk_liters", null: false
    t.datetime "canceled_at"
    t.string   "canceled_reason"
    t.integer  "canceled_by_id"
    t.text     "notes"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "product_options", ["canceled_by_id"], name: "index_product_options_on_canceled_by_id", using: :btree

  create_table "share_certificates", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "sent_at"
    t.date     "payed_at"
    t.date     "returned_at"
    t.text     "notes"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "value_in_chf"
  end

  add_index "share_certificates", ["user_id"], name: "index_share_certificates_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.boolean  "admin",                     default: false, null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "postal_address"
    t.string   "postal_code"
    t.string   "city"
    t.string   "country"
    t.string   "tel_mobile"
    t.string   "tel_home"
    t.string   "tel_office"
    t.string   "status"
    t.text     "notes"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "remember_digest"
    t.datetime "last_seen_at"
    t.datetime "remembered_since"
    t.boolean  "activated",                 default: false
    t.datetime "activated_at"
    t.datetime "activation_sent_at"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "last_login_at"
    t.string   "last_login_from"
    t.string   "postal_address_supplement"
    t.integer  "seen_count",                default: 0,     null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",          null: false
    t.integer  "item_id",            null: false
    t.string   "event",              null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.string   "request_remote_ip"
    t.string   "request_user_agent"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

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
end
