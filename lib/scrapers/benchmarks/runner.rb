module Scrapers::Benchmarks
  class Runner < Scrapers::Base::Runner
    def self.options
      {
        high_url: 'http://www.videocardbenchmark.net/high_end_gpus.html',
        mid_url: 'http://www.videocardbenchmark.net/mid_range_gpus.html',
        midlow_url: 'http://www.videocardbenchmark.net/midlow_range_gpus.html',
        low_url: 'http://www.videocardbenchmark.net/low_end_gpus.html'
      }
    end

    def run!

      urls = [options[:high_url], options[:mid_url], options[:midlow_url], options[:low_url]]

      @loader = Scrapers::Loader.new(PageProcessor, urls)
      @loader.scrap do |scrap_request|
        scrap_request.output.each do |data|
          data_process(data, Gpu.find_by_name(data[:name]) || Gpu.new)
        end
      end
    end

    def data_process(data, gpu)
      processor = Scrapers::Base::DataProcessor.new(data, gpu)
      gpu = processor.process
      gpu.save!
    end
  end
end
