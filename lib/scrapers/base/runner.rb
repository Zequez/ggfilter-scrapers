module Scrapers
  module Base
    class Runner
      def self.options
        {
          continue_with_errors: false,
          headers: {},
          resources: nil,
          resource_class: nil
        }
      end

      attr_reader :error

      def initialize(options = {})
        @options = self.class.options.merge(options)
      end


      def total_count
        @total_count ||= resources && resources.size
      end

      def run
        @report = Scrapers::ScrapReport.new name
        @report.start
        log_start

        run!

        @report.finish
        @report.scraper_report = self.report_msg unless @report.error?
        log_end(@report)
        @report
      end

      def options
        @options
      end

      def resource_class
        @options[:resource_class]
      end

      def name
        'base_runner'
      end

      protected

      def run!
        scrap do |output|

        end
      end

      def processor
        raise 'Virtual method Runner#processor'
      end

      def urls
        raise 'Virtual method Runner#urls'
      end

      def resources
        @resources ||= options[:resources]
      end

      # Only works if you mapped the URLs from resources
      def resource_from_url(url)
        resources[urls.index(url)]
      end

      def loader
        @loader ||= Loader.new(
          processor,
          urls,
          continue_with_errors: @options[:continue_with_errors],
          headers: @options[:headers]
        )
      end

      def scrap(&block)
        @left_count = total_count
        begin
          loader.scrap do |output, url|
            @left_count -= 1 if total_count
            if @options[:resources]
              block.call(output, resource_from_url(url))
            else
              block.call(output)
            end
          end
          true
        rescue Scrapers::Errors::ScrapError => e
          Scrapers.logger.error 'Error scraping: ' + e.message
          @report.error! e
          false
        end
      end

      def report_msg
        ''
      end

      def game_log_text(game)
        left = total_count ? " | #{@left_count} / #{total_count}" : ''
        log_id = game.steam_id.to_s.ljust(10)
        name = game.name.blank? ? '<No name>' : game.name
        "#{log_id} #{name} #{left}"
      end

      def log_start
        log_text = "#{self.name} running!"
          .colorize(:color => :black, :background => :yellow)
        Scrapers.logger.info log_text

        if resources
          Scrapers.logger.info "#{resources.size} to scrap!"
        end
      end

      def log_end(report)
        log_text = "#{self.name} finished! Time elapsed: #{report.elapsed_time_human}"
          .colorize(:color => :black, :background => :light_yellow)
        Scrapers.logger.info log_text
      end
    end
  end
end
