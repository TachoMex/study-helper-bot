# frozen_string_literal: true

class ReminderSchedule < ActiveRecord::Base
  belongs_to :user
end
