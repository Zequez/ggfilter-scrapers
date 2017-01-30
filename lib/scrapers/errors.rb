module Scrapers
  module Errors
    class ScrapError < StandardError
      attr_reader :response, :message, :backtrace

      def initialize(message, backtrace, response)
        @message = message
        @response = response
        @backtrace = backtrace
      end

      def html
        (@response && @response.body) || ''
      end

      def url
        (@response && @response.request.url) || ''
      end
    end

    class LoadingError < ScrapError
    end

    class InvalidPageError < ScrapError
    end
  end
end
