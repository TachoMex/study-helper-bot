# frozen_string_literal: true

require 'kybus/bot'
require 'kybus/configs'
require './bot/base'
require 'sequel'
require 'active_record'
require './models/question'
require './models/questionnaire'
require './models/reminder_schedule'
require './models/topic'
require './models/user'
require './models/reminder_reply'
require './models/pending_file_upload'
require './models/siiau_search'

module Services
  class << self
    attr_reader :conf, :conf_manager, :services

    def configure_services!
      Dir.mkdir('storage') unless Dir.exist?('storage')
      @conf_manager = Kybus::Configuration.auto_load!
      @conf = @conf_manager.configs
      @services = @conf_manager.all_services
      configure_active_record!
    end

    def bot
      @bot ||= bot = BrodhaBot::Base.new(Services.conf['bots']['main'])
    end

    def sequel_connection_for_active_record
      data = conf['active_record'].clone
      # since sequel and active record require it by distinct, this allows the config to have
      # one single key
      data['adapter'] = 'sqlite' if data['adapter'] == 'sqlite3'
      @sequel_connection_for_active_record ||= Sequel.connect(data)
    end

    def bot_database
      @bot_database ||= Sequel.connect(Services.conf['bots']['main']['state_repository']['endpoint'])
    end

    def configure_active_record!
      ActiveRecord::Base.establish_connection(conf['active_record'])
    end
  end
end
