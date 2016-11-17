

module Scrapers
  class Loader
    def initialize(processor_class, urls = [], options = {})
      @processor_class = processor_class
      @options = {
        headers: {},
        page_processor_abort_after: 1,
        request_abort_after: 1,
        request_retry_count: 3,
        request_retry_delay: 1000,
        request_timeout: 5000,
        concurrency: 3,
        follow_location: false
      }.merge(options)
      @urls = urls
      @loader = TrueLoader.new(@options)
    end

    def scrap(&block)
      @urls.each do |url|
        processor = @processor_class.new(url, @loader)
        begin
          processor.load do |output|
            Scrapers.logger.info 'Yielding to runner'
            block.call(output, url)
          end
        rescue LoadingError => e
          Scrapers.logger.info 'Had a loading error!'
        rescue InvalidPageError => e
          Scrapers.logger.info 'Had an invalid page error!'
        end
      end
      @loader.run do |response|
        Scrapers.logger.info 'Request finished'
      end
    end
  end

  # class Loader
  #   attr_reader :data
  #
  #   def initialize(processor, urls = [], options = {})
  #     default_options = {
  #       headers: {},
  #       page_processor_abort_after: 1,
  #       request_abort_after: 1,
  #       request_retry_count: 3,
  #       request_retry_delay: 1000,
  #       request_timeout: 5000,
  #       follow_location: false,
  #
  #       continue_with_errors: false
  #     }
  #     @options = default_options.merge(options)
  #
  #     @processor = processor
  #
  #     @multi_urls = urls.kind_of? Array
  #     @urls =  @multi_urls ? urls : [urls]
  #
  #     injector = @processor.method(:inject)
  #     @scrap_requests = @urls.each_with_index.map do |url, i|
  #       RootScrapRequest.new(url, injector)
  #     end
  #
  #     @hydra = Typhoeus::Hydra.hydra
  #   end
  #
  #   def scrap(yield_type: :request, yield_with_errors: false, collect: nil, &block)
  #     raise 'Unknown yield type' unless [:group, :request]
  #
  #     @data = {}
  #     @yield_block = block
  #     @yield_type = yield_type
  #     @yield_with_errors = yield_with_errors
  #     @yield_collect = collect.nil? ? !block_given? : collect
  #     @scrap_requests.each do |scrap_request|
  #       add_to_queue scrap_request
  #     end
  #     @hydra.run
  #
  #     return_values
  #   end
  #
  #   private
  #
  #   def return_values
  #     data = consolidated_output_hash
  #     if @yield_collect
  #       @multi_urls ? data : data.values.first
  #     end
  #   end
  #
  #   def consolidated_output_hash
  #     outputs = {}
  #     inject = @processor.method(:inject)
  #     @scrap_requests.map do |scrap_request|
  #       outputs[scrap_request.url] = scrap_request.consolidated_output(&inject)
  #     end
  #     outputs
  #   end
  #
  #   def process_response(scrap_request)
  #     if scrap_request.error?
  #       Scrapers.logger.error "Error loading page #{scrap_request.url} Error code: #{scrap_request.response.code}"
  #     else
  #       processor = create_processor(scrap_request)
  #
  #       load_time = scrap_request.response.total_time
  #       Scrapers.logger.info "Parsing #{scrap_request.url} | Load time: #{load_time}".light_black
  #
  #       begin
  #         output = processor.process_page
  #       rescue StandardError => e
  #         scrap_request.error!
  #         Scrapers.logger.error "Error parsing #{scrap_request.url}"
  #         Scrapers.logger.store_error_page scrap_request, e
  #         raise e unless @options[:continue_with_errors]
  #       else
  #         scrap_request.set_output output
  #       end
  #     end
  #
  #     if yield_scrap_request(scrap_request)
  #       destroy_scrap_request(scrap_request) unless @yield_collect
  #     end
  #   end
  #
  #   def create_processor(scrap_request)
  #     @processor.new(scrap_request) do |url|
  #       add_to_queue scrap_request.subrequest!(url), front: true
  #     end
  #   end
  #
  #   def yield_scrap_request(scrap_request)
  #     if @yield_block
  #       if @yield_type == :group
  #         if scrap_request.root.all_finished?
  #           if @yield_with_errors or not scrap_request.root.any_error?
  #             @yield_block.call(scrap_request.root)
  #             return true
  #           end
  #         end
  #       else
  #         if @yield_with_errors or not scrap_request.error?
  #           @yield_block.call(scrap_request)
  #           return true
  #         end
  #       end
  #     end
  #     false
  #   end
  #
  #   # This allows less memory usage
  #   def destroy_scrap_request(scrap_request)
  #     scrap_request.destroy
  #     @scrap_requests.delete(scrap_request)
  #   end
  #
  #   def add_to_queue(scrap_request, front: false)
  #     if scrap_request
  #       match_processor!(scrap_request.url)
  #       request = Typhoeus::Request.new(scrap_request.url, headers: @options[:headers], followlocation: true)
  #       request.on_complete do |response|
  #         scrap_request.set_response response
  #         scrap_request.finished!
  #         scrap_request.error! if not response.success?
  #         process_response scrap_request
  #         scrap_request.clear_response
  #       end
  #       front ? @hydra.queue_front(request) : @hydra.queue(request)
  #     end
  #   end
  #
  #   def match_processor!(url)
  #     no_processor_error(url) unless @processor.regexp.match url
  #   end
  #
  #   def no_processor_error(url)
  #     raise NoPageProcessorFoundError.new("Couldn't find processor for #{url} \n Active processor: #{@processor.class}")
  #   end
  # end
end
