# frozen_string_literal: true

module MediaDownloaderController
  DEFAULT_STORAGE = './storage'

  def download_and_send_video(user, url, format, path)
    user_id = user.id
    case format
    when '/audio'
      files = downloader.get_audio(url, path)
      files.each { |file| async_file_send(user_id, 'audio', file) }
      send(:send_message, 'Unsupported or no videos found', user.channel_id) if files.empty?
    when '/video'
      files = downloader.get(url, path)
      files.each { |file| async_file_send(user_id, 'video', file) }
      send(:send_message, 'Unsupported or no videos found', user.channel_id) if files.empty?
    when '/cancel'
      send_message('cancelled')
    end
  end

  def downloader
    @downloader ||= VideoDownloader.new(DEFAULT_STORAGE)
  end

  def async_file_send(user_id, type, path)
    log_info('Enqueuing file download', file: path)
    User.find(user_id).pending_file_uploads.create(media_type: type, file_path: path, storage_type: 'local', status: 0, retries: 0,
                                     last_updated: Time.now, created_at: Time.now)
  end

  def pending_reminders_query
    adapter = ActiveRecord::Base.connection.adapter_name
    case adapter
    when 'SQLite'
      <<-SQL
        SELECT user_id
        FROM   reminder_schedules
        WHERE  begin_reminders_at < ?
          AND  finish_reminders_at > ?
          AND  (last_question_sent_at IS NULL OR DATETIME(last_question_sent_at, frequency || ' minutes' ) < ?)
      SQL
    when 'PostgreSQL'
      <<-SQL
        SELECT user_id
        FROM   reminder_schedules
        WHERE  begin_reminders_at < ?
          AND  finish_reminders_at > ?
          AND  (last_question_sent_at IS NULL OR last_question_sent_at + INTERVAL '1 minute' * frequency < ?)
      SQL
    else
      raise "Reminders daemon not implemented for #{adapter} DB engine"
    end
  end

  def run_reminders_daemon
    loop do
      query = pending_reminders_query
      current_time = Time.now.strftime('%H:%M')
      sanitized = ActiveRecord::Base.send(:sanitize_sql_array,
                                          [query, current_time, current_time, Time.now.to_s[..-7]])
      ActiveRecord::Base.connection.execute(sanitized).each do |user_id|
        user = User.find(user_id['user_id'])

        log_info('Sending remider to user', user: user.id)
        questionnaire = user.questionnaires.with_reminders.order('RANDOM()').limit(1).first

        question = questionnaire&.questions&.order('RANDOM()')&.limit(1)&.first

        next if question.nil?

        message = send_message(user.channel_id,
                               "Pregunta para repasar 🤓.\nHablemos de #{questionnaire.topic.name}. \n#{questionnaire.name}:\n#{question.contents}")
        reminders = user.reminder_schedule
        reminders.last_question_sent_at = Time.now.to_s[..-7]
        reminders.save
        user.reminder_replies.create(question_id: question.id, message_id: message.message_id, created_at: Time.now,
                                     last_updated: Time.now)
      end

      sleep(60)
    end
  end

  def run_pending_downloads_daemon
    loop do
      log_info('Running downloads daemon')
      PendingDownload.where(status: 0).each do |download|
        log_info('Trying to download', url: download.url, user: download.user.id, format: download.format)
        download.status = 1
        download.save!
        download_and_send_video(download.user, download.url, download.format, download.user.id)
        download.status = 2
        download.save!
      rescue StandardError => e
        log_error('Error at download', error: e, trace: e.backtrace)
        if download.retries <= 3
          download.retries += 1
          download.status = 0
        else
          download.status = 3
        end
        download.save!
      end
      sleep(60)
    end
  end

  def self.register_commands(bot)
    bot.extend(MediaDownloaderController)
    bot.register_command(URI::DEFAULT_PARSER.make_regexp, format: '/audio /video /cancel') do
      user = current_bot_user
      if user.premium?
        user.pending_downloads.create(
          url: command_name,
          format: params[:format],
          status: 0,
          created_at: Time.now,
          last_updated: Time.now
        )
        send_message('Descargando...')
      else
        send_message('Esto sólo está disponible para usuarios premium')
      end
    end
  end
end
