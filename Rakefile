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
    Services.run_migrations!
  end
end

namespace :daemons do
  desc 'Run daemons'
  task :reminders do
    require './lib/services'
    Services.configure_services!
    Services.bot.run_reminders_daemon
  end

  task :file_uploader do
    require './lib/services'
    Services.configure_services!
    Services.bot.run_files_daemon
  end

  task :downloader do
    require './lib/services'
    Services.configure_services!
    Services.bot.run_pending_downloads_daemon
  end

  task :siiau do
    require './lib/services'
    Services.configure_services!
    Services.bot.run_siiau_daemon
  end
end
