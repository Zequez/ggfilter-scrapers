module Scrapers
  class TrueLoader
    def initialize(options = {})
      @options = {
        headers: {},
        request_retry_count: 3,
        request_retry_delay: 1000,
        request_timeout: 5000,
        follow_location: false,
        concurrency: 10, # Don't set this too low or it exits for no reason
      }.merge(options)
      @hydra = Typhoeus::Hydra.new(max_concurrency: @options[:concurrency])
    end

    def queue(url, retry_count = nil, front = false, &cb)
      retry_count ||= @options[:request_retry_count]
      request = build_request(url) do |response|
        if response.success?
          cb.call(response)
          @callback.call(response)
        else
          retry_count -= 1
          if retry_count == 0
            raise Scrapers::Errors::LoadingError.new(
              "Could not load the page #{response.code} status code | #{url}", response
            )
          else
            # We want to pause Hydra here for a few seconds, but I don't
            # know how to do it, once it starts you either stop it, or finish it
            # I need to dig deeper.
            # And no, sleeping here doesn't do anything, hydra ain't waiting for noone
            queue(url, retry_count, front, &cb)
          end
        end
      end
      front ? @hydra.queue_front(request) : @hydra.queue(request)
    end

    def queue_front(url, &cb)
      queue(url, nil, true, &cb)
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
