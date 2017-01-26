module Scrapers
  module Base
    class PageProcessor
      def initialize(html)
        @html = html
        @doc = Nokogiri::HTML(@html)
      end

      def process_page
        nil
      end

      def css(matcher, parent = @doc)
        parent.search(matcher)
      end

      def css!(matcher, parent = @doc)
        result = css(matcher, parent)
        if result.empty?
          raise "Could not find #{matcher}"
        end
        return result
      end
    end
  end
end
