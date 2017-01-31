module Scrapers
  class ScrapReport
    attr_reader :started_at, :finished_at, :errors, :warnings
    attr_accessor :scraper_report, :output, :aborted

    def initialize
      @errors = []
      @warnings = []
      @aborted = false
      @output = nil
    end

    def aborted?
      aborted
    end

    def errors?
      errors.size > 0
    end

    def warnings?
      warnings.size > 0
    end

    def add_error(error)
      Scrapers.logger.error error.message
      Scrapers.logger.ln error.backtrace
      errors.push error
    end

    def add_warning(warning)
      Scrapers.logger.warn warning

      warnings.push warning
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
  end
end
