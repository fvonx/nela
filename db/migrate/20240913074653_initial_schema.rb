# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[7.2]
  def change
    create_table "conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "title"
      t.uuid "protocol_ref", null: false
      t.datetime "seen_at"
      t.uuid "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id"], name: "index_conversations_on_user_id"
    end
  
    create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "sender", null: false
      t.string "receivers", default: [], array: true
      t.string "title"
      t.text "body", null: false
      t.integer "status", default: 0, null: false
      t.integer "direction", default: 0, null: false
      t.uuid "protocol_ref", null: false
      t.datetime "handshaked_at"
      t.uuid "conversation_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["conversation_id"], name: "index_messages_on_conversation_id"
      t.index ["receivers"], name: "index_messages_on_receivers", using: :gin
    end
  
    create_table "nela_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "sender", null: false
      t.string "direct_receiver", null: false
      t.string "all_receivers", default: [], array: true
      t.string "title"
      t.text "body", null: false
      t.uuid "message_ref", null: false
      t.uuid "conversation_ref", null: false
      t.uuid "handshake_ref", null: false
      t.datetime "handshaked_at"
      t.integer "direction", default: 0, null: false
      t.uuid "message_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["message_id"], name: "index_nela_messages_on_message_id"
    end
  
    create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "handle", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["handle"], name: "index_users_on_handle", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    end
  
    add_foreign_key "conversations", "users"
    add_foreign_key "messages", "conversations"
    add_foreign_key "nela_messages", "messages"
  end
end