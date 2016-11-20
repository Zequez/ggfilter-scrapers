module Scrapers
  module Errors
    class ScrapAbortError < StandardError
      def initialize(cause)
        @message = cause.message
        @cause = cause
        @response = cause.response
        @request = cause.response.request
      end

      attr_accessor :message, :cause, :html, :url, :response, :request

      def html
        @cause.response.body
      end

      def url
        @cause.response.request.url
      end
    end

    class ScrapError < StandardError
      def initialize(message, response, original_e = nil)
        @message = message
        @response = response
        @original_e = original_e
      end

      attr_accessor :message, :response, :original_e
    end

    class LoadingError < ScrapError
    end

    class InvalidPageError < ScrapError
    end
  end
end
