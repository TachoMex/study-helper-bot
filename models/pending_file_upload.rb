# frozen_string_literal: true

class PendingFileUpload < ActiveRecord::Base
  belongs_to :user
end
