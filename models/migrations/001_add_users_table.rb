# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :channel_id, size: 64, unique: true, index: true, null: false
      DateTime :created_at, null: false
      DateTime :last_updated, null: false
      String :lang, size: 2
    end
  end
end
