module Scrapers
  module Base
    class PageProcessor
      def initialize(url, loader)
        @url = url
        @loader = loader
        @queued = 0
      end

      def load(&cb)
        @queued += 1
        @loader.queue(@url) do |response|
          @queued -= 1
          process_response(response, &cb)
        end
      end

      def process_response(response, &cb)
        @response = response
        @doc = Nokogiri::HTML(response.body)

        begin
          process_page do |output|
            cb.call(output) if cb
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
        processor.load(&cb)
      end
    end
  end
end
