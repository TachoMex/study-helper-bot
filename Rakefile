# frozen_string_literal: true

require 'rake/testtask'
task default: :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.warning = false
  t.pattern = 'test/**/test_*\.rb'
  t.warning = false
end

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    require './lib/services'
    require 'kybus/bot/migrator'

    Services.configure_services!

    require_relative 'lib/services'
    Services.configure_services!
    Kybus::Bot::Migrator.run_migrations!(Services.bot_database)
    require 'sequel/core'
    Sequel.extension :migration
    Sequel::Migrator.run(Services.sequel_connection_for_active_record, 'models/migrations')
  end
end
