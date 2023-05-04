# frozen_string_literal: true

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'SIIAU'
end

class SIIAUSearch < ActiveRecord::Base
  belongs_to :user
end