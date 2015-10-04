module Scrapers
  class BasePageProcessor
    def initialize(response, initial = true, url_data = {}, &add_to_queue)
      @response = response
      @request = response.request
      @initial = initial
      @url_data = url_data
      @url = response.request.url
      @doc = Nokogiri::HTML(response.body)
      @add_to_queue = add_to_queue
    end

    attr_accessor :data

    def process_page_and_store(all_data)
      @data = process_page
      inject(all_data)
    end

    def process_page
      raise NotImplementedError.new('#process_page is an abstract method')
    end

    def add_to_queue(url)
      @add_to_queue.call(url)
    end

    def css(matcher)
      @doc.search(matcher)
    end

    def inject(data)
      @data
    end

    def self.regexp(value = nil)
      (@regexp = value if value) || @regexp || /(?!)/
    end
  end
end
