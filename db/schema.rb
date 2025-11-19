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

ActiveRecord::Schema[8.1].define(version: 2025_09_22_151918) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "admin_users", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "gravatar_type", default: "retro", null: false
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_admin_users_on_username", unique: true
  end

  create_table "dictionary_words", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "definition"
    t.string "part_of_speech", null: false
    t.string "synsets", default: [], array: true
    t.datetime "updated_at", null: false
    t.string "word", null: false
    t.index ["part_of_speech"], name: "index_dictionary_words_on_part_of_speech"
    t.index ["word"], name: "index_dictionary_words_on_word"
  end

  create_table "poems", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "content"
    t.datetime "created_at", null: false
    t.boolean "is_public", default: true, null: false
    t.bigint "source_text_id", null: false
    t.string "technique_used"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_poems_on_author"
    t.index ["source_text_id"], name: "index_poems_on_source_text_id"
  end

  create_table "source_texts", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "gutenberg_id"
    t.boolean "is_public", default: true, null: false
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["gutenberg_id"], name: "index_source_texts_on_gutenberg_id_public_unique", unique: true, where: "((is_public = true) AND (gutenberg_id IS NOT NULL))"
    t.index ["owner_type", "owner_id"], name: "index_source_texts_on_owner_type_and_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "gravatar_type", default: "retro", null: false
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "poems", "source_texts"
end
