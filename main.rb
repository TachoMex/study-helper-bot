# frozen_string_literal: true

require 'awesome_print'
require 'kybus/logger'
require_relative 'lib/cron'
require_relative 'lib/services'

Services.configure_services!

Services.bot.run if $PROGRAM_NAME == __FILE__
