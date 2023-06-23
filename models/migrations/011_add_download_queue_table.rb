# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:pending_downloads) do
      primary_key :id
      foreign_key :user_id, :users, key: :id
      String :url, size: 512
      String :format, size: 10
      Integer :status, null: false
      Integer :retries, null: false, default: 0
      DateTime :created_at, null: false
      DateTime :last_updated, null: false
    end
  end
end
