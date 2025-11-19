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

ActiveRecord::Schema[8.1].define(version: 2025_11_19_154725) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "posts", force: :cascade do |t|
    t.integer "comments", default: 0, null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "external_id"
    t.string "hashtags"
    t.boolean "is_promoted", default: false, null: false
    t.integer "likes", default: 0, null: false
    t.string "location"
    t.string "media_type"
    t.string "media_url"
    t.string "mentions"
    t.string "profile_image"
    t.integer "shares", default: 0, null: false
    t.bigint "source_id", null: false
    t.datetime "updated_at", null: false
    t.integer "views", default: 0, null: false
    t.index ["external_id"], name: "index_posts_on_external_id", unique: true
    t.index ["media_type", "created_at"], name: "index_posts_on_media_type_and_created_at"
    t.index ["media_type", "views"], name: "index_posts_on_media_type_and_views"
    t.index ["source_id", "created_at"], name: "index_posts_on_source_and_created_at"
    t.index ["source_id"], name: "index_posts_on_source_id"
    t.index ["views"], name: "index_posts_on_views_desc"
  end

  create_table "sources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "external_id"
    t.string "platform", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["external_id"], name: "index_sources_on_external_id", unique: true
    t.index ["platform", "username"], name: "index_sources_on_platform_and_username", unique: true
  end

  add_foreign_key "posts", "sources"
end
