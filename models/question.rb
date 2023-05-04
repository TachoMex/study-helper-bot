# frozen_string_literal: true

class Question < ActiveRecord::Base
  belongs_to :questionnaire
  belongs_to :user
  has_many :reminder_replies
end
