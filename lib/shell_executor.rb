# frozen_string_literal: true

class ShellExecutor
  def initialize; end

  def run(command, args)
    cmd = "#{Shellwords.escape(command)} #{expand_args(args)}"
    puts "Running shell command: #{cmd}"
    `#{cmd}`
    puts 'Done'
  end

  def expand_args(args)
    args.map { |key, val| "#{expand_key(key)} #{expand_value(val)}" }
        .join(' ')
  end

  def expand_key(key)
    case key
    when String
      Shellwords.escape(key)
    when Symbol
      Shellwords.escape("--#{key.to_s.gsub('_', '-')}")
    end
  end

  def expand_value(val)
    val && Shellwords.escape(val.to_s)
  end
end
