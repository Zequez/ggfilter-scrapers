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
require 'scrapers/scrap_request'
require 'scrapers/root_scrap_request'
require 'scrapers/loader'

require 'scrapers/base/page_processor'
require 'scrapers/base/data_processor'
require 'scrapers/base/runner'

require 'scrapers/steam/migration'
require 'scrapers/steam/steam_game'
require 'scrapers/steam/game/data_processor'
require 'scrapers/steam/game/page_processor'
require 'scrapers/steam/game/runner'
require 'scrapers/steam/list/data_processor'
require 'scrapers/steam/list/page_processor'
require 'scrapers/steam/list/runner'
require 'scrapers/steam/reviews/data_processor'
require 'scrapers/steam/reviews/page_processor'
require 'scrapers/steam/reviews/runner'

require 'scrapers/benchmarks/migration'
require 'scrapers/benchmarks/gpu'
require 'scrapers/benchmarks/page_processor'
require 'scrapers/benchmarks/runner'
