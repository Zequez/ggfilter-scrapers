module Scrapers
  class BasicRunner
    class << self
      @@instant_raise = Scrapers.env == 'test' || Scrapers.env == 'development'
      def instant_raise=(val); @@instant_raise = val end
      def instant_raise; @@instant_raise end
    end

    def report
      @report ||= Scrapers::ScrapReport.new
    end

    def loader_options
      {}
    end

    def loader
      @loader ||= Loader.new(loader_options)
    end

    def run
      begin
        Scrapers.logger.info "Scraping started #{self.class.name}"
        report.start
        run!
        report.finish
        report.scraper_report = report_message
        Scrapers.logger.info "Scraping finished #{self.class.name} | #{report.elapsed_time_human}"
      rescue StandardError => e
        loader.abort
        report.add_error e
        report.aborted = true
        report.output = nil
        raise if self.class.instant_raise
      end

      report
    end

    def report_message
      ''
    end

    def queue(url, front: false, &cb)
      loader.queue(url, front: front) do |response|
        if continue_parsing?(response)
          begin
            cb.call(response)
          rescue StandardError => e
            e = decorate_exception(e, response)
            report.add_error e
            raise if self.class.instant_raise
          end
        end

        if report.errors.size > 10
          raise 'Too many errors, aborting scrap'
        end
      end
    end

    def continue_parsing?(response)
      if response.success?
        true
      else
        begin
          loader.retry!(response)
        rescue StandardError => e
          e = decorate_exception(e, response)
          report.add_error e
          raise if self.class.instant_raise
        end
        false
      end
    end

    def decorate_exception(e, response)
      unless e.kind_of? Errors::ScrapError
        e = Errors::ScrapError.new(e.message, e.backtrace, response)
      end
      e
    end
  end
end
