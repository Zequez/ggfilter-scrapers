module Scrapers
  class TrueLoader
    def initialize(options = {})
      @options = {
        headers: {},
        request_timeout: 5000,
        follow_location: false,
        concurrency: 10, # Don't set this too low or it exits for no reason
      }.merge(options)
      @hydra = Typhoeus::Hydra.new(max_concurrency: @options[:concurrency])
    end

    def queue(url, front = false, &cb)
      request = build_request(url) do |response|
        cb.call(response)
        @callback.call(response)
      end
      front ? @hydra.queue_front(request) : @hydra.queue(request)
    end

    def queue_front(url, &cb)
      queue(url, true, &cb)
    end

    def run(&callback)
      @callback = callback
      @hydra.run
    end

    private

    def build_request(url, &on_complete)
      request = Typhoeus::Request.new(
        url,
        headers: @options[:headers],
        followlocation: @options[:follow_location],
        timeout_ms: @options[:request_timeout]
      )
      request.on_complete(&on_complete)
      request
    end
  end
end
