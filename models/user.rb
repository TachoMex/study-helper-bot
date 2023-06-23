# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :topics
  has_many :questions
  has_many :questionnaires
  has_one :reminder_schedule
  has_many :reminder_replies
  has_many :pending_file_uploads
  has_many :siiau_searches
  has_many :pending_downloads

  class QuestionnaireNotFound < StandardError
  end

  def premium?
    premium == true
  end

  def fetch_questionnaire!(id)
    questionnaires.find_by(id:) || raise(QuestionnaireNotFound)
  end

  serialize :other_settings, JSON
end
