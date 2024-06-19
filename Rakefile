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
    require_relative 'config_loaders/autoconfig'
    run_migrations!
  end
end

namespace :daemons do
  desc 'Run daemons'
  task :reminders do
    require_relative 'config_loaders/autoconfig'
    BOT.run_reminders_daemon
  end

  task :file_uploader do
    require_relative 'config_loaders/autoconfig'
    BOT.run_files_daemon
  end

  task :downloader do
    require_relative 'config_loaders/autoconfig'
    BOT.run_pending_downloads_daemon
  end
end
