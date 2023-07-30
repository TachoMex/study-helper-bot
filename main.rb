# frozen_string_literal: true

require 'awesome_print'
require 'kybus/logger'
require_relative 'lib/services'

# :nocov:
if $PROGRAM_NAME == __FILE__
  Services.configure_services!
  Services.bot.run
elsif $PROGRAM_NAME.end_with? 'sidekiq'
  Services.configure_services!
  Services.bot
end
# :nocov:
