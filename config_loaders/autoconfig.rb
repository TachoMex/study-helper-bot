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
require './models/game_session'
require './models/pending_download'

CONF_MANAGER = Kybus::Configuration.auto_load!
APP_CONF = CONF_MANAGER.configs

FileUtils.mkdir_p('storage')

require_relative "sequel"
require_relative "active_record"
require_relative "bot_maker"

def sequel_connection_for_active_record
  data = APP_CONF['active_record'].clone
  # since sequel and active record require it by distinct, this allows the config to have
  # one single key
  data['adapter'] = 'sqlite' if data['adapter'] == 'sqlite3'
  Sequel.connect(data)
end


def run_migrations!
  require 'kybus/bot/migrator'
  require 'sequel/core'
  Kybus::Bot::Migrator.run_migrations!(APP_CONF['bots']['main']['state_repository'])
  Sequel.extension :migration
  Sequel::Migrator.run(sequel_connection_for_active_record, 'models/migrations')
end