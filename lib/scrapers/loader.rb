module Scrapers
  class Loader
    def initialize(options = {})
      @options = {
        headers: {},
        request_timeout: 5000,
        follow_location: false,
        concurrency: 10, # Don't set this too low or it exits for no reason
        retry_limit: 3
      }.merge(options)
      @hydra = Typhoeus::Hydra.new(max_concurrency: @options[:concurrency])
      @urls_retries = {}
    end

    def retry!(response)
      url = response.request.url
      @urls_retries[url] ||= 0
      @urls_retries[url] += 1
      if @urls_retries[url] <= @options[:retry_limit]
        queue(url)
      else
        raise "Could not load the page #{response.code} status code (retried #{@urls_retries[url]} times) | #{url}"
      end
    end

    def queue(url, front: false, &cb)
      request = build_request(url, &cb)
      front ? @hydra.queue_front(request) : @hydra.queue(request)
    end

    def queue_front(url, &cb)
      queue(url, true, &cb)
    end

    def run
      @hydra.run
    end

    def abort
      @hydra.abort
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
