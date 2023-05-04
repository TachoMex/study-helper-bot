# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:questions) do
      primary_key :id
      Text :contents, null: false
      Text :answer, null: false
      # String :user_id, size: 64, unique: true, index: true, null: false
      foreign_key :user_id, :users, key: :id
      foreign_key :topic_id, :topics, key: :id
      foreign_key :questionnaire_id, :questionnaires, key: :id
      TrueClass :archived, default: false, null: false
      DateTime :created_at, null: false
      DateTime :last_updated, null: false
    end
  end
end
