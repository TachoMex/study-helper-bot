# frozen_string_literal: true

module MediaDownloaderController
  DEFAULT_STORAGE = './storage'

  def download_and_send_video(url, format, path)
    case format
    when '/audio'
      files = downloader.get_audio(url, path)
      files.each { |file| async_file_send(current_bot_user, 'audio', file) }
      dsl.send(:send_message, 'Unsupported or no videos found') if files.empty?
    when '/video'
      files = downloader.get(url, path)
      files.each { |file| async_file_send(current_bot_user, 'video', file) }
      dsl.send(:send_message, 'Unsupported or no videos found') if files.empty?
    when '/cancel'
      send_message('cancelled')
    end
  end

  def downloader
    @downloader ||= VideoDownloader.new(DEFAULT_STORAGE)
  end

  def async_file_send(user, type, path)
    log_info('Enqueuing file download', file: path)
    user.pending_file_uploads.create(media_type: type, file_path: path, storage_type: 'local', status: 0, retries: 0,
                                     last_updated: Time.now, created_at: Time.now)
  end

  def self.register_commands(bot)
    bot.extend(MediaDownloaderController)
    bot.register_command(URI::DEFAULT_PARSER.make_regexp, format: '/audio /video /cancel') do
      download_and_send_video(command_name, params[:format], current_user)
    end
  end
end
