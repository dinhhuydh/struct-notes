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

ActiveRecord::Schema[8.0].define(version: 2026_05_28_163333) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "hook"
    t.json "body_sections"
    t.text "best_for"
    t.text "not_for"
    t.text "ethics_notes"
    t.json "key_facts"
    t.text "raw_notes"
    t.string "status", default: "draft", null: false
    t.integer "user_id", null: false
    t.integer "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tone", default: "magazine_editorial", null: false
    t.bigint "parent_id"
    t.integer "version_number", default: 1, null: false
    t.index ["parent_id"], name: "index_articles_on_parent_id"
    t.index ["template_id"], name: "index_articles_on_template_id"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.text "prompt_template"
    t.json "schema"
    t.boolean "is_default", default: false, null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_templates_on_slug", unique: true
    t.index ["user_id"], name: "index_templates_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.integer "generation_limit", default: 20, null: false
    t.integer "generations_this_month", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plan", default: "free", null: false
    t.datetime "generation_count_reset_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "articles", "articles", column: "parent_id", on_delete: :nullify
  add_foreign_key "articles", "templates"
  add_foreign_key "articles", "users"
  add_foreign_key "templates", "users"
end
