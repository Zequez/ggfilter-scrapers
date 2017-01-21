module Scrapers
  module Base
    class PageProcessor
      def max_retries; 3 end
      def front_load; false end
      def error_on_redirect; true end

      def initialize(url, loader)
        @url = url
        @loader = loader
        @nested_processors = []
        # @errors = []
        # @warnings = []
      end

      def load(&cb)
        @load_cb ||= cb
        @loader.queue(@url, front_load) do |response|
          process_response(response)
        end
      end

      def retry!
        @retries ||= 0
        @retries += 1
        if @retries < max_retries
          load
        else
          raise Scrapers::Errors::LoadingError.new(
            "Could not load the page #{@response.code} status code | #{@url}", @response
          )
        end
      end

      def process_response(response)
        @response = response
        process_header
      end

      def process_header
        if @response.success?
          run_process_page
        elsif @response.headers && @response.headers['Location']
          # do nothing
        else
          retry!
        end
      end

      def run_process_page
        @doc = Nokogiri::HTML(@response.body)
        begin
          process_page do |output|
            @load_cb.call(output) if @load_cb
          end
        rescue StandardError => e
          raise Scrapers::Errors::InvalidPageError.new("Error inside #process_page: #{e.message}", @response, e)
        end
      end

      def process_page
        raise NotImplementedError.new('#process_page is an abstract method')
      end

      def css(matcher, parent = @doc)
        parent.search(matcher)
      end

      def css!(matcher, parent = @doc)
        result = css(matcher, parent)
        if result.empty?
          raise Scrapers::Errors::InvalidPageError.new('Could not find ' + matcher, @response)
        end
        return result
      end

      def add(url, processor_class = self.class, &cb)
        processor = processor_class.new(url, @loader)
        @nested_processors.push(processor)
        processor.load(&cb)
      end

      # # Unexpected errors with the page
      # # that should be checked
      # # like the page missing a vital element
      # def error!(msg)
      #   @errors.push([msg, @response])
      # end
      #
      # # Expected errors with the page
      # # that are probably temporal, like a
      # # redirect or something
      # def warning!(msg)
      #   @warnings.push([msg, @response])
      # end
    end
  end
end
