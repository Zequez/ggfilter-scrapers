require 'logger'
require 'nokogiri'
require 'typhoeus'
require 'active_record'
require 'colorize'
require 'awesome_print'
require 'i18n_data'
require 'fileutils'
require 'active_support/concern'

module Scrapers
  ROOT = Pathname.new(__dir__) + '..'

  class NoPageProcessorFoundError < StandardError; end
  class InvalidProcessorError < StandardError; end

  def self.app_root
    @app_root ||= defined?(Rails) ? Rails.root : ROOT
  end

  def self.logger
    @error_log ||= begin

    end

    @logger ||= begin
      logfile = File.open("#{app_root}/log/scrapers.log", 'a')  # create log file
      logfile.sync = true  # automatically flushes data to file
      CustomLogger.new(logfile)
    end
  end
end

require 'scrapers/version'
require 'scrapers/custom_logger'
require 'scrapers/base_page_processor'
require 'scrapers/base_runner'
require 'scrapers/base_migration'
require 'scrapers/scrap_request'
require 'scrapers/loader'
require 'scrapers/steam_game'
require 'scrapers/steam_game/data_processor'
require 'scrapers/steam_game/game_extension'
require 'scrapers/steam_game/migration'
require 'scrapers/steam_game/page_processor'
require 'scrapers/steam_game/runner'
require 'scrapers/steam_list'
require 'scrapers/steam_list/data_processor'
require 'scrapers/steam_list/game_extension'
require 'scrapers/steam_list/migration'
require 'scrapers/steam_list/page_processor'
require 'scrapers/steam_list/runner'
require 'scrapers/steam_reviews'
require 'scrapers/steam_reviews/data_processor'
require 'scrapers/steam_reviews/game_extension'
require 'scrapers/steam_reviews/migration'
require 'scrapers/steam_reviews/page_processor'
require 'scrapers/steam_reviews/runner'
