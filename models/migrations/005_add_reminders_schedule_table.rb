# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:reminder_schedules) do
      primary_key :id
      foreign_key :user_id, :users, key: :id
      Integer :frequency, default: 600, null: false
      String :begin_reminders_at, default: '10:00', null: false
      String :finish_reminders_at, default: '18:00', null: false
      DateTime :last_question_sent_at, null: true
      DateTime :created_at, null: false
      DateTime :last_updated, null: false
    end
  end
end
