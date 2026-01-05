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

ActiveRecord::Schema[8.1].define(version: 2025_11_21_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.integer "action"
    t.datetime "created_at", null: false
    t.json "metadata"
    t.bigint "target_id", null: false
    t.string "target_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["target_type", "target_id"], name: "index_activities_on_target"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_comments_on_event_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "event_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "emoji"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "event_checklist_items", force: :cascade do |t|
    t.bigint "assignee_id"
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "due_at"
    t.bigint "event_checklist_id", null: false
    t.bigint "event_id", null: false
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_event_checklist_items_on_assignee_id"
    t.index ["event_checklist_id", "position"], name: "index_event_checklist_items_on_event_checklist_id_and_position"
    t.index ["event_checklist_id"], name: "index_event_checklist_items_on_event_checklist_id"
    t.index ["event_id"], name: "index_event_checklist_items_on_event_id"
  end

  create_table "event_checklists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "position"], name: "index_event_checklists_on_event_id_and_position"
    t.index ["event_id"], name: "index_event_checklists_on_event_id"
  end

  create_table "event_participations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "rsvp_status", default: "pending"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_event_participations_on_event_id"
    t.index ["user_id"], name: "index_event_participations_on_user_id"
  end

  create_table "event_suggestions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "status"
    t.datetime "suggested_end_time"
    t.datetime "suggested_start_time"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_event_suggestions_on_event_id"
    t.index ["user_id"], name: "index_event_suggestions_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "end_time"
    t.bigint "event_category_id"
    t.integer "group_id"
    t.float "latitude"
    t.string "location"
    t.float "longitude"
    t.integer "share_clicks", default: 0, null: false
    t.string "share_token"
    t.integer "share_views", default: 0, null: false
    t.string "slug"
    t.datetime "start_time"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "visibility"
    t.index ["event_category_id"], name: "index_events_on_event_category_id"
    t.index ["share_token"], name: "index_events_on_share_token", unique: true
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "friend_id"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "likeable_id", null: false
    t.string "likeable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "missions", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.boolean "auto_assign", default: true, null: false
    t.string "category", default: "weekend", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "reward_badge"
    t.integer "reward_xp", default: 0, null: false
    t.integer "target_value", default: 1, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_missions_on_key", unique: true
  end

  create_table "plans", force: :cascade do |t|
    t.integer "annual_price_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.jsonb "features", default: [], null: false
    t.boolean "highlighted", default: false, null: false
    t.string "key", null: false
    t.integer "max_active_events"
    t.integer "monthly_price_cents", default: 0, null: false
    t.string "name", null: false
    t.integer "priority", default: 0, null: false
    t.string "tagline"
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_plans_on_key", unique: true
  end

  create_table "role_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "resource_id"
    t.string "resource_type"
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["resource_type", "resource_id"], name: "index_role_assignments_on_resource"
    t.index ["role_id"], name: "index_role_assignments_on_role_id"
    t.index ["user_id", "role_id", "resource_type", "resource_id"], name: "idx_role_assignments_unique", unique: true
    t.index ["user_id"], name: "index_role_assignments_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_roles_on_key", unique: true
  end

  create_table "rsvps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "sub_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.bigint "event_id", null: false
    t.string "location"
    t.text "notes"
    t.integer "position", default: 0, null: false
    t.datetime "start_time"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "position"], name: "index_sub_events_on_event_id_and_position"
    t.index ["event_id", "start_time"], name: "index_sub_events_on_event_id_and_start_time"
    t.index ["event_id"], name: "index_sub_events_on_event_id"
  end

  create_table "user_missions", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.jsonb "metadata", default: {}, null: false
    t.bigint "mission_id", null: false
    t.integer "progress", default: 0, null: false
    t.string "status", default: "pending", null: false
    t.integer "target_value", default: 1, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["mission_id"], name: "index_user_missions_on_mission_id"
    t.index ["user_id", "mission_id", "status"], name: "index_user_missions_on_user_and_mission_and_status"
    t.index ["user_id"], name: "index_user_missions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.date "birthday"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.jsonb "cosmetic_unlocks", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "fcm_token"
    t.string "first_name"
    t.string "last_name"
    t.bigint "plan_id", null: false
    t.string "platform"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "tag"
    t.string "theme_preference", default: "light", null: false
    t.string "uid"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.string "username"
    t.integer "xp", default: 0, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["plan_id"], name: "index_users_on_plan_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tag"], name: "index_users_on_tag", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
    t.index ["xp"], name: "index_users_on_xp"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "users"
  add_foreign_key "comments", "events"
  add_foreign_key "comments", "users"
  add_foreign_key "event_checklist_items", "event_checklists"
  add_foreign_key "event_checklist_items", "events"
  add_foreign_key "event_checklist_items", "users", column: "assignee_id"
  add_foreign_key "event_checklists", "events"
  add_foreign_key "event_participations", "events"
  add_foreign_key "event_participations", "users"
  add_foreign_key "event_suggestions", "events"
  add_foreign_key "event_suggestions", "users"
  add_foreign_key "events", "event_categories"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "role_assignments", "roles"
  add_foreign_key "role_assignments", "users"
  add_foreign_key "sub_events", "events"
  add_foreign_key "user_missions", "missions"
  add_foreign_key "user_missions", "users"
  add_foreign_key "users", "plans"
end
