# frozen_string_literal: true

class ReminderReply < ActiveRecord::Base
  belongs_to :question
  belongs_to :user
end
