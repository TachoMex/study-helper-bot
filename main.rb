# frozen_string_literal: true

require 'awesome_print'
require 'kybus/logger'
require_relative 'config_loaders/autoconfig'

# :nocov:
if $PROGRAM_NAME == __FILE__
  if ENV['WITH_DAEMONS']
    bot = BOT
    %i[run_reminders_daemon run_files_daemon run_pending_downloads_daemon ].each do |daemon_name|
      Thread.new {bot.send(daemon_name)}
    end
  end
  BOT.run
elsif $PROGRAM_NAME.end_with? 'sidekiq'
  BOT
end
# :nocov:
