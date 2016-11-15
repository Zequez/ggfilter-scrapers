module Scrapers
  class RootScrapRequest < ScrapRequest
    attr_reader :requests, :subrequests

    def initialize(url, injector)
      super(url, url, self)

      @injector = injector
      @consolidated_output = nil
      @requests = [self]
      @subrequests = []
    end

    def all_finished?
      @requests.all?(&:finished?)
    end

    def any_error?
      @requests.any?(&:error?)
    end

    def was_url_requested?(url)
      @requests.any?{ |r| r.url == url }
    end

    def consolidated_output
      @requests.reject(&:error?).map(&:output).inject(nil, &@injector)
    end

    def add_subrequest(scrap_request)
      @requests.push(scrap_request)
      @subrequests.push(scrap_request)
      scrap_request
    end
  end
end
