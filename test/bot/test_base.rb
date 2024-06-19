# frozen_string_literal: true

require './test/test_helper'

module BrodhaBot
  class TestBase < BotTest
    def test_default_command
      @bot.expects(:send_message).with('/help')
      @bot.receives('something not in commands')
    end

    def test_register_user
      @bot.expects(:send_message).with('¡Bienvenido! Puedes empezar añadiendo una materia para comenzar a estudiar /agregar_materia. También puedes ver la ayuda /help')
      register_user
    end

    def test_register_user_already_registered
      register_user
      msg = @bot.receives('/iniciar')
      assert_equal('Ya has iniciado el bot. /help te mostrará la ayuda.', msg.raw_message)
    end

    def test_help_command
      msg = @bot.receives('/help')
      refute_nil(msg.raw_message)
    end

    def test_set_reminders_schedule
      register_user
      @bot.receives('/horarios_estudio')
      msg = @bot.receives('15')
      assert_equal('Preferencias guardadas.', msg.raw_message)
    end
  end
end
