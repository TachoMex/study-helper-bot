# frozen_string_literal: true

class GameSession < ActiveRecord::Base
  serialize :meta, coder: JSON
end
