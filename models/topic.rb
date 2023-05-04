# frozen_string_literal: true

class Topic < ActiveRecord::Base
  has_many :questionnaires
  belongs_to :user
end
