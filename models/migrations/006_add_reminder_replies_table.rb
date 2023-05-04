# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:reminder_replies) do
      primary_key :id
      foreign_key :user_id, :users, key: :id
      foreign_key :question_id, :questions, key: :id
      TrueClass :replied, null: false, default: false
      String :message_id, null: false, index: true
      DateTime :last_updated, null: false
      DateTime :created_at, null: false
    end
  end
end
