require 'typhoeus'

module Scrapers
  class Loader
    attr_reader :data

    def initialize(initial_url, processor, headers = {})
      if initial_url.kind_of? Hash
        @initial_urls_data = initial_url
        @initial_urls = initial_url.keys
        @multi_urls = true
      elsif initial_url.kind_of? Array
        @initial_urls_data = {}
        @initial_urls = initial_url
        @multi_urls = true
      else
        @initial_urls_data = {}
        @initial_urls = [initial_url]
        @multi_urls = false
      end

      @headers = headers
      @processor = processor
      @hydra = Typhoeus::Hydra.hydra
      @urls_queued = []
    end

    def scrap(&block)
      @data = {}
      @yieldBlock = block
      @initial_urls.each do |initial_url|
        add_to_queue initial_url, initial_url
      end
      @hydra.run

      @multi_urls ? @data : @data.values.first
    end

    private

    def process_response(response, initial_url)
      request_url = response.request.url
      data_for_proc = @initial_urls_data[initial_url]
      initial_request = (request_url == initial_url)
      processor = @processor.new(response, initial_request, data_for_proc) do |url|
        add_to_queue(url, initial_url)
      end
      Scrapers.logger.info "Parsing #{response.request.url}"

      @data[initial_url] = processor.process_page_and_store @data[initial_url]
      yield_page_data processor.data, initial_url, request_url
    end

    def add_to_queue(url, initial_url)
      unless @urls_queued.include? url
        match_processor!(url)
        request = Typhoeus::Request.new(url, headers: @headers)
        request.on_complete do |response|
          process_response response, initial_url
        end
        @urls_queued << url
        @hydra.queue request
      end
    end

    def yield_page_data(page_data, initial_url, url)
      if @yieldBlock
        page_data = [page_data] unless page_data.kind_of? Array
        page_data.each do |data|
          @yieldBlock.curry[data, initial_url, url]
        end
      end
    end

    def match_processor!(url)
      no_processor_error(url) unless @processor.regexp.match url
    end

    def no_processor_error(url)
      raise NoPageProcessorFoundError.new("Couldn't find processor for #{url} \n Active processor: #{@processor.class}")
    end
  end
end
