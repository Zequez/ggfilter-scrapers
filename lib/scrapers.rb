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

  def self.env
    (defined?(Rails) && Rails.env) || ENV['RAILS_ENV']
  end

  def self.logger
    @error_log ||= begin

    end

    @logger ||= begin
      if Scrapers.env == 'test'
        logfile = File.open("#{app_root}/log/scrapers.log", 'a')  # create log file
        logfile.sync = true  # automatically flushes data to file
        CustomLogger.new(logfile)
      else
        $stdout.sync = true
        CustomLogger.new(STDOUT)
      end
    end
  end
end

require 'scrapers/version'
require 'scrapers/custom_logger'
require 'scrapers/errors'
require 'scrapers/scrap_report'
require 'scrapers/loader'

require 'scrapers/basic_runner'
require 'scrapers/base/page_processor'

require 'scrapers/steam/game'
require 'scrapers/steam/game/page_processor'
require 'scrapers/steam/game/runner'
require 'scrapers/steam/list'
require 'scrapers/steam/list/page_processor'
require 'scrapers/steam/list/runner'
require 'scrapers/steam/reviews'
require 'scrapers/steam/reviews/page_processor'
require 'scrapers/steam/reviews/runner'

require 'scrapers/oculus/page_processor'
require 'scrapers/oculus/runner'

require 'scrapers/benchmarks/page_processor'
require 'scrapers/benchmarks/runner'
