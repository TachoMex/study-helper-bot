# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:pending_file_uploads) do
      primary_key :id
      foreign_key :user_id, :users, key: :id
      String :file_path, null: false
      String :storage_type, null: false
      String :media_type, null: false, size: 10
      Integer :status, null: false
      Integer :retries
      DateTime :last_updated, null: false
      DateTime :created_at, null: false
    end
  end
end
