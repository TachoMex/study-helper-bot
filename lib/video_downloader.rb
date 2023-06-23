# frozen_string_literal: true

require 'securerandom'
require 'fileutils'
require_relative 'shell_executor'

class VideoDownloader
  def initialize(base_path)
    @base_path = base_path
    FileUtils.mkdir_p(base_path)
  end

  def get(url, save_at)
    FileUtils.mkdir_p("#{@base_path}/#{save_at}")
    list_file = "#{@base_path}/#{save_at}/#{random_string}.txt"
    FileUtils.touch(list_file)
    shell_executer.run('yt-dlp',
                       '-o' => "#{@base_path}/#{save_at}/%(title)s-%(id)s.%(ext)s",
                       download_archive: list_file,
                       ignore_errors: nil,
                       nil => url)
    list_file_expand(list_file, save_at, %w[mp4 mkv gif])
  end

  def get_audio(url, save_at)
    list_file = "#{@base_path}/#{save_at}/#{random_string}.txt"
    FileUtils.mkdir_p("#{@base_path}/#{save_at}")
    FileUtils.touch(list_file)
    shell_executer.run('yt-dlp',
                       '-o' => "#{@base_path}/#{save_at}/%(title)s-%(id)s.%(ext)s",
                       ignore_errors: nil,
                       extract_audio: nil,
                       audio_format: 'mp3',
                       audio_quality: 0,
                       keep_video: nil,
                       add_metadata: nil,
                       embed_thumbnail: nil,
                       download_archive: list_file,
                       nil => url)
    list_file_expand(list_file, save_at, ['mp3'])
  end

  def list_file_expand(list, path, formats)
    File.readlines(list)
        .map { |line| line.strip.split[1] }
        .map { |file| Dir.glob(formats.map { |format| "#{@base_path}/#{path}/*#{file}*.#{format}" }).first }
        .compact
  end

  def shell_executer
    ShellExecutor.new
  end

  def random_string
    SecureRandom.hex
  end
end
