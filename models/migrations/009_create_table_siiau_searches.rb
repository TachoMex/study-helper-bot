# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:siiau_searches) do
      primary_key :id
      foreign_key :user_id, :users, key: :id
      String :subject, null: false, size: 32
      String :nrc, null: false, size: 5
      String :center, null: false, size: 5
      String :cycle, null: false, size: 10
      String :program, null: false, size: 8
      TrueClass :found, default: false, null: false
      DateTime :created_at, null: false
      DateTime :last_updated, null: false
    end
  end
end
