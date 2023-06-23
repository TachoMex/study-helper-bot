# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:game_sessions) do
      primary_key :id
      foreign_key :user_id, :users, key: :id
      String :name, size: 32
      Integer :status, null: false
      String :meta, null: false, text: true
      DateTime :created_at, null: false
      DateTime :last_updated, null: false
    end
  end
end
