# frozen_string_literal: true

require 'uri'
require './lib/video_downloader'
require_relative 'commands/media_download_controller'
require_relative 'commands/user_controller'
require_relative 'commands/questionnaire_controller'
require_relative 'commands/siiau_availability_controller'

module BrodhaBot
  class Base < Kybus::Bot::Base
    class UserNotRegistered < StandardError
    end

    def initialize(*args)
      super

      register_command('default') do
        if last_message.reply?
          reply = last_message.replied_message
          user = current_bot_user
          reply_reminder = ReminderReply.find_by(user_id: user.id, message_id: reply.message_id)
          if reply_reminder.nil?
            send_message('/help')
            next
          end
          send_message("La respuesta correcta es:\n#{reply_reminder.question.answer}")
        else
          send_message('/help')
        end
      end

      rescue_from(::BrodhaBot::Base::UserNotRegistered) do
        send_message('Por favor inicia el bot /iniciar')
      end

      rescue_from(StandardError) do
        log_error('Unexpected error in bot', error: params[:_last_exception], trace: params[:_last_exception].backtrace)
        send_message('Error inesperado')
      end

      MediaDownloaderController.register_commands(self)
      QuestionnaireController.register_commands(self)
      UserController.register_commands(self)
      SIIAUAvailabilityController.register_commands(self)
    end

    def run_reminders_daemon
      loop do
        current_time = Time.now.strftime('%H:%M')
        query = <<-SQL
          SELECT user_id
          FROM   reminder_schedules
          WHERE  begin_reminders_at < ?
            AND  finish_reminders_at > ?
            AND  (last_question_sent_at IS NULL OR DATETIME(last_question_sent_at, frequency || ' minutes' ) < ?)
        SQL
        sanitized = ActiveRecord::Base.send(:sanitize_sql_array,
                                            [query, current_time, current_time, Time.now.to_s[..-7]])
        ActiveRecord::Base.connection.execute(sanitized).each do |user_id|
          user = User.find(user_id['user_id'])
          log_info('Sending remider to user', user: user.id)
          questionnaire = user.questionnaires.with_reminders.order('RANDOM()').limit(1).first
          question = questionnaire.questions.order('RANDOM()').limit(1).first
          message = send_message(user.channel_id,
                                 "Pregunta para repasar 🤓.\nHablemos de #{questionnaire.topic.name}. \n#{questionnaire.name}:\n#{question.contents}")
          reminders = user.reminder_schedule
          reminders.last_question_sent_at = Time.now.to_s[..-7]
          reminders.save
          user.reminder_replies.create(question_id: question.id, message_id: message.message_id, created_at: Time.now,
                                       last_updated: Time.now)
          log_info('Message sent to user', message_id: message.message_id)
        end

        sleep(60)
      end
    end

    def run_files_daemon
      file = PendingFileUpload.where(status: 0).first
      if file
        begin
          type = "send_#{file.media_type}".to_sym
          channel = file.user.channel_id
          log_info('Seding upload', path: file.file_path, type:, channel:)
          dsl.send(type, file.file_path, channel)
          sleep(1)
          file.status = 1
          file.save!
        rescue StandardError
          file.retries += 1
          file.status = 2 if retries >= 3
          file.save!
          raise
        end
      else
        log_info('Waiting for files')
        sleep(60)
      end
    end

    def start_daemons!
      %i[run_reminders_daemon run_files_daemon run_siiau_daemon].each do |daemon|
        Thread.new do
          loop do
            Services.bot.send(daemon)
          rescue StandardError => e
            log_error('Error in daemon', daemon:, e:, trace: e.backtrace)
            sleep(60)
          end
        end
      end
    end

    def run
      start_daemons!
      super
    end

    def bot_started?
      user = User.find_by(channel_id: dsl.current_channel)
      !!user
    end

    def current_bot_user
      user = User.find_by(channel_id: dsl.current_channel)
      raise UserNotRegistered if user.nil?

      user
    end

    def premium_user?
      current_bot_user.premium?
    end
  end
end
