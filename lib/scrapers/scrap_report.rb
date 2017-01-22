module Scrapers
  class ScrapReport
    attr_reader :started_at, :finished_at, :exception, :scraper_name
    attr_accessor :scraper_report, :output

    def initialize(scraper_name)
      @scraper_name = scraper_name
      @error = false
      @exception = nil
    end

    def error!(exception)
      @error = true
      @exception = exception
    end

    def error?
      @error
    end

    def start
      @started_at = Time.now
    end

    def finish
      @finished_at = Time.now
    end

    def elapsed_time
      (@finished_at - @started_at).round(2)
    end

    def elapsed_time_human
      et = elapsed_time
      elapsed_minutes = (et / 60).floor
      elapsed_seconds = (et % 60).floor
      "#{elapsed_minutes}m #{elapsed_seconds}s"
    end

    def error_reporter(options = {})
      if error?
        Scrapers::ErrorReporter.new @exception, @scraper_name, options
      else
        nil
      end
    end

    def report_errors_if_any(options = {})
      if error?
        error_reporter(options).commit
      end
    end
  end
end
