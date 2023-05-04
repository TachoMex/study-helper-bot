# frozen_string_literal: true

class Questionnaire < ActiveRecord::Base
  has_many :questions
  belongs_to :topic
  belongs_to :user

  scope :with_reminders, -> { where(reminders_active: true) }
end
