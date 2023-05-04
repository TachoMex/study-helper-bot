# frozen_string_literal: true

Sequel.migration do
  up do
    add_column(:users, :premium, TrueClass, default: false)
    add_column(:users, :other_settings, :text, default: '{}')
  end
end
