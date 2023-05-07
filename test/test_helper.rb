# frozen_string_literal: true

ENV['BRODHAACTIVE_RECORD__DATABASE'] = 'storage/test.db'

require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rack-minitest/test'
require 'rdoc'
require 'webmock/minitest'
require 'mocha/minitest'

SimpleCov.minimum_coverage 68
SimpleCov.start

require 'kybus/bot/test'
require_relative '../main'

class BotTest < Minitest::Test
  def setup
    @bot ||= BrodhaBot::Base.make_test_bot('channel_id' => "test_channel_#{rand(1..1_000_000_000)}",
                                           'inline_args' => true)
    nil
  end

  def register_user
    @bot.receives('/iniciar')
  end

  def check_difference(exp)
    initial = eval(exp)
    yield
    refute_equal(initial, eval(exp))
  end

  def register_topic(name)
    @bot.receives('/agregar_materia')
    response = @bot.receives(name).raw_message
    topic_id = response[%r{/agregar_cuestionario\d*}, 0].gsub('/agregar_cuestionario', '')
    topic_id.to_i
  end
end

Services.configure_services!
FileUtils.rm_rf(Services.conf['active_record']['database'])
Services.run_migrations!
