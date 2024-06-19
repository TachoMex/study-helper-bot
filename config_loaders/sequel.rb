require 'sequel'

bot_state_config = APP_CONF['bots']['main']['state_repository']
BOT_DB = Sequel.connect(bot_state_config['endpoint'])