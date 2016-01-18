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

ActiveRecord::Schema.define(version: 20160117154735) do

  create_table "job_signups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "job_signups", ["job_id"], name: "index_job_signups_on_job_id"
  add_index "job_signups", ["user_id"], name: "index_job_signups_on_user_id"

  create_table "jobs", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "place"
    t.string   "address"
    t.integer  "slots"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "jobs", ["user_id"], name: "index_jobs_on_user_id"

  create_table "share_certificates", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "sent_at"
    t.date     "payed_at"
    t.date     "returned_at"
    t.text     "notes"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "share_certificates", ["user_id"], name: "index_share_certificates_on_user_id"

  create_table "signups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "signups", ["job_id"], name: "index_signups_on_job_id"
  add_index "signups", ["user_id"], name: "index_signups_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.boolean  "admin",              default: false, null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "postal_address"
    t.string   "postal_code"
    t.string   "city"
    t.string   "country"
    t.string   "tel_mobile"
    t.string   "tel_home"
    t.string   "tel_office"
    t.integer  "status"
    t.text     "notes"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "remember_digest"
    t.datetime "last_seen_at"
    t.datetime "remembered_since"
    t.boolean  "activated",          default: false
    t.datetime "activated_at"
    t.datetime "activation_sent_at"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "last_login_at"
    t.string   "last_login_from"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",                             null: false
    t.integer  "item_id",                               null: false
    t.string   "event",                                 null: false
    t.string   "whodunnit"
    t.text     "object",             limit: 1073741823
    t.datetime "created_at"
    t.text     "object_changes",     limit: 1073741823
    t.string   "request_remote_ip"
    t.string   "request_user_agent"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
