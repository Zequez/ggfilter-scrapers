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

      def run
        log_text = "#{self.class} running!"
          .colorize(:color => :black, :background => :yellow)
        Scrapers.logger.info log_text

        if resources
          Scrapers.logger.info "#{resources.size} to scrap!"
        end

        start_time = Time.now

        run!

        elapsed_time = (Time.now - start_time)
        elapsed_minutes = (elapsed_time / 60).floor
        elapsed_seconds = (elapsed_time % 60).floor

        log_text = "#{self.class} finished! Time elapsed: #{elapsed_minutes}m #{elapsed_seconds}s"
          .colorize(:color => :black, :background => :light_yellow)
        Scrapers.logger.info log_text
      end

      def options
        @options
      end

      def resource_class
        @options[:resource_class]
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
        begin
          loader.scrap do |output, url|
            if @options[:resources]
              block.call(output, resource_from_url(url))
            else
              block.call(output)
            end
          end
          true
        rescue Scrapers::Errors::ScrapAbortError => e
          Scrapers.logger.error 'Error scraping: ' + e.message
          @error = Scrapers::ErrorReporter.new(e, name).commit
          false
        end
      end

      def game_log_text(game)
        log_id = game.steam_id.to_s.ljust(10)
        name = game.name.blank? ? '<No name>' : game.name
        "#{log_id} #{name}"
      end
    end
  end
end
