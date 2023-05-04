# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :topics
  has_many :questions
  has_many :questionnaires
  has_one :reminder_schedule
  has_many :reminder_replies
  has_many :pending_file_uploads
  has_many :siiau_searches

  def premium?
    premium == true
  end

  serialize :other_settings, JSON

  # def settings_to_json
  #   self.other_settings = other_settings.to_json
  # end

  # include Kybus::Logger
  # def settings_from_json
  #   log_info('Loaded user, parsing other settings', other_settings:)
  #   self.other_settings = if other_settings == ''
  #                           {}
  #                         else
  #                           JSON.parse(other_settings, symbolize_names: true)
  #                         end

  #   log_info('Loaded user, after parsed settings', other_settings: other_settings)
  # end

  # before_save :settings_to_json
  # after_save :settings_from_json
  # after_find :settings_from_json
  # after_initialize :settings_from_json
end
