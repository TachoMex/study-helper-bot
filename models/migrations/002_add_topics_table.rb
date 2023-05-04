# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:topics) do
      primary_key :id
      String :name, size: 64, null: false
      foreign_key :user_id, :users, key: :id
      # String :user_id, size: 64, unique: true, index: true, null: false
      TrueClass :archived, default: false, null: false
      DateTime :created_at, null: false
      DateTime :last_updated, null: false
    end
  end
end
