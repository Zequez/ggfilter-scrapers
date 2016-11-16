module Scrapers::Base
  class PageProcessor
    def initialize(scrap_request, &add_to_queue)
      @scrap_request = scrap_request
      @response      = scrap_request.response
      @request       = scrap_request.request
      @root_url      = scrap_request.root_url
      @url           = scrap_request.url

      @doc = Nokogiri::HTML(@response.body)
      @add_to_queue = add_to_queue
    end

    attr_accessor :data

    def process_page
      raise NotImplementedError.new('#process_page is an abstract method')
    end

    def add_to_queue(url)
      @add_to_queue.call(url) if @add_to_queue
    end

    def css(matcher, parent = @doc)
      parent.search(matcher)
    end

    def css!(matcher, parent = @doc)
      result = css(matcher, parent)
      if result.empty?
        raise Scrapers::InvalidPageError.new('Could not find ' + matcher)
      end
      return result
    end

    def self.inject(all_data, data)
      data
    end

    def self.regexp(value = nil)
      (@regexp = value if value) || @regexp || /./
    end
  end
end
