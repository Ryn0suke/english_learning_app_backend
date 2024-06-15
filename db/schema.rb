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

ActiveRecord::Schema[7.0].define(version: 2024_06_15_080933) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "phrase_tag_relations", force: :cascade do |t|
    t.bigint "phrase_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phrase_id"], name: "index_phrase_tag_relations_on_phrase_id"
    t.index ["tag_id"], name: "index_phrase_tag_relations_on_tag_id"
  end

  create_table "phrases", force: :cascade do |t|
    t.text "japanese"
    t.text "english"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "created_at"], name: "index_phrases_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_phrases_on_user_id"
  end

  create_table "tag_user_relations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_tag_user_relations_on_tag_id"
    t.index ["user_id", "tag_id"], name: "index_tag_user_relations_on_user_id_and_tag_id", unique: true
    t.index ["user_id"], name: "index_tag_user_relations_on_user_id"
  end

  create_table "tag_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_tag_users_on_tag_id"
    t.index ["user_id"], name: "index_tag_users_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "phrase_tag_relations", "phrases"
  add_foreign_key "phrase_tag_relations", "tags"
  add_foreign_key "phrases", "users"
  add_foreign_key "tag_user_relations", "tags"
  add_foreign_key "tag_user_relations", "users"
  add_foreign_key "tag_users", "tags"
  add_foreign_key "tag_users", "users"
end
