module Scrapers
  class LoadingError < StandardError

  end

  class TrueLoader
    def initialize(options = {})
      @options = {
        headers: {},
        request_retry_count: 3,
        request_retry_delay: 1000,
        request_timeout: 5000,
        follow_location: false,
        concurrency: 3,
      }.merge(options)
      @hydra = Typhoeus::Hydra.new(max_concurrency: @options[:concurrency])
    end

    def queue(url, retry_count = @options[:request_retry_count], &cb)
      request = Typhoeus::Request.new(
        url,
        headers: @options[:headers],
        followlocation: @options[:follow_location],
        timeout_ms: @options[:request_timeout]
      )
      request.on_complete do |response|
        if response.success?
          cb.call(response)
          @callback.call(response)
        else
          retry_count -= 1
          if retry_count == 0
            raise LoadingError.new("Could not load the page #{response.status} status code | #{url}")
          else
            # sleep(@options[:request_retry_delay])
            queue(url, retry_count, &cb)
          end
        end
      end
      @hydra.queue(request)
    end

    def run(&callback)
      @callback = callback
      @hydra.run
    end
  end
end
