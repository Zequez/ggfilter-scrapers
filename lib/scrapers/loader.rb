module Scrapers
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
          block.call(output, url)
        end
      end

      begin
        @loader.run do |response|
          # Any request finished
        end
      rescue Scrapers::Errors::LoadingError, Scrapers::Errors::InvalidPageError => e
        # Here we should try to continue with errors or something
        raise e
      end
    end
  end
end
