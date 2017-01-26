module Scrapers
  module Errors
    class ScrapError < StandardError
      attr_reader :response, :message, :backtrace

      def initialize(original_message, original_backtrace, response)
        @message = message
        @response = response
        @backtrace = backtrace
      end

      # def initialize(message, response = nil, original_e = nil)
      #   @message = message
      #   # @response = response
      #   # @request = @response && @response.request
      #   # @original_e = original_e
      # end
      #
      # attr_accessor :message, :response, :request, :original_e
      # def set_response(response)
      #   @response = response
      # end

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
