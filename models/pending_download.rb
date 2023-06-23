# frozen_string_literal: true

class PendingDownload < ActiveRecord::Base
  belongs_to :user
end
