module Scrapers::Benchmarks
  class Runner < Scrapers::Base::Runner
    def processor; PageProcessor end

    def self.options
      super.merge({
        high_url: 'http://www.videocardbenchmark.net/high_end_gpus.html',
        mid_url: 'http://www.videocardbenchmark.net/mid_range_gpus.html',
        midlow_url: 'http://www.videocardbenchmark.net/midlow_range_gpus.html',
        low_url: 'http://www.videocardbenchmark.net/low_end_gpus.html'
      })
    end

    def urls
      [options[:high_url], options[:mid_url], options[:midlow_url], options[:low_url]]
    end

    def run!
      scrap do |output|
        output.each do |gpu_data|
          data_process(gpu_data, Gpu.find_by_name(gpu_data[:name]) || Gpu.new)
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
