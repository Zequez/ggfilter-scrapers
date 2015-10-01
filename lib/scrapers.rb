require 'logger'
require 'nokogiri'
require 'typhoeus'
require 'active_record'
require 'colorize'

module Scrapers
  ROOT = Pathname.new(__dir__) + '..'

  class NoPageProcessorFoundError < StandardError; end
  class InvalidProcessorError < StandardError; end

  def self.logger
    @logger ||= begin
      logfile = File.open("#{ROOT}/log/scrapers.log", 'a')  # create log file
      logfile.sync = true  # automatically flushes data to file
      CustomLogger.new(logfile)  # constant accessible anywhere
    end
  end

  class CustomLogger < Logger
    @@colors = {
      fatal: :red,
      error: :red,
      warn: :orange,
      info: :blue
    }

    def format_message(severity, timestamp, progname, msg)
      output = "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
      sev = severity.downcase.to_sym
      output = output.send(@@colors[sev]) if @@colors[sev]
      output
    end

    def l(msg)
      self << "#{msg.inspect}\n"
    end

    def la(msg)
      self << "#{msg.ai}\n"
    end

    def ln(msg)
      self << "#{msg}\n"
    end
  end
end

require 'scrapers/version'
require 'scrapers/base_page_processor'
require 'scrapers/base_runner'
require 'scrapers/loader'
require 'scrapers/steam_game'
require 'scrapers/steam_game/data_processor'
require 'scrapers/steam_game/game_extension'
require 'scrapers/steam_game/migration'
require 'scrapers/steam_game/page_processor'
require 'scrapers/steam_list'
require 'scrapers/steam_list/data_processor'
require 'scrapers/steam_list/game_extension'
require 'scrapers/steam_list/migration'
require 'scrapers/steam_list/page_processor'
require 'scrapers/steam_list/runner'
