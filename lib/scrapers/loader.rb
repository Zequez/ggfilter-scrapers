module Scrapers
  class Loader
    attr_reader :data

    def initialize(processor, urls = [], inputs = nil, resources = nil, options = {})
      @processor = processor

      @multi_urls = urls.kind_of? Array
      urls_array      = @multi_urls ? urls : [urls]
      inputs_array    = inputs    ? (@multi_urls ? inputs : [inputs])       : []
      resources_array = resources ? (@multi_urls ? resources : [resources]) : []

      raise ArgumentError.new('urls.size != inputs.size')     if inputs && urls_array.size != inputs_array.size
      raise  ArgumentError.new('urls.size != resources.size') if resources && urls_array.size != resources_array.size

      injector = @processor.method(:inject)
      @scrap_requests = urls_array.each_with_index.map do |url, i|
        RootScrapRequest.new(url, inputs_array[i], resources_array[i], injector)
      end

      @options = {
        headers: {},
        continue_with_errors: false
      }.merge(options)

      @hydra = Typhoeus::Hydra.hydra
    end

    def scrap(&block)
      raise 'Unknown yield type' unless [:group, :request, :request_array]

      @data = {}
      @yieldBlock = block
      @scrap_requests.each do |scrap_request|
        add_to_queue scrap_request
      end
      @hydra.run

      @data = consolidated_output_hash

      @multi_urls ? @data : @data.values.first
    end

    private

    def consolidated_output_hash
      outputs = {}
      inject = @processor.method(:inject)
      @scrap_requests.map do |scrap_request|
        outputs[scrap_request.url] = scrap_request.consolidated_output(&inject)
      end
      outputs
    end

    def process_response(scrap_request)
      processor = @processor.new(scrap_request) do |url|
        add_to_queue scrap_request.subrequest!(url)
      end

      load_time = scrap_request.response.total_time
      Scrapers.logger.info "Parsing #{scrap_request.url} | Load time: #{load_time}".light_black

      begin
        output = processor.process_page
      rescue StandardError => e
        scrap_request.error!
        scrap_request.finished!
        Scrapers.logger.error "Error parsing #{scrap_request.url}"
        Scrapers.logger.store_error_page scrap_request, e
        raise e unless @options[:continue_with_errors]
      else
        scrap_request.set_output output
        scrap_request.finished!

        @yieldBlock.call(scrap_request) if @yieldBlock
      end
    end

    def add_to_queue(scrap_request)
      if scrap_request
        match_processor!(scrap_request.url)
        request = Typhoeus::Request.new(scrap_request.url, headers: @options[:headers], followlocation: true)
        request.on_complete do |response|
          scrap_request.set_response response

          if response.success?
            process_response scrap_request
          else
            Scrapers.logger.error "Error loading page #{scrap_request.url} Error code: #{response.code}"
          end
        end
        @hydra.queue request
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
