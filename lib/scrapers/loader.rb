module Scrapers
  class ScrapAbortError < StandardError
    def initialize(cause)
      @message = 'Scrap aborted: ' + cause.message
      @cause = cause
    end

    attr_accessor :cause
  end

  class Loader
    def initialize(processor_class, urls = [], loader_options = {})
      @processor_class = processor_class
      @urls = urls
      @loader = TrueLoader.new(loader_options)
    end

    def scrap(&block)
      @urls.each do |url|
        processor = @processor_class.new(url, @loader)
        processor.load do |output|
          Scrapers.logger.info 'Yielding to runner'
          block.call(output, url)
        end
      end

      begin
        @loader.run do |response|
          Scrapers.logger.info 'Request finished'
        end
      rescue LoadingError => e
        raise ScrapAbortError.new(e)
      rescue InvalidPageError => e
        raise ScrapAbortError.new(e)
      end
    end
  end
end
