module Scrapers::Benchmarks
  class Runner < Scrapers::BasicRunner
    URLS = [
      'http://www.videocardbenchmark.net/high_end_gpus.html',
      'http://www.videocardbenchmark.net/mid_range_gpus.html',
      'http://www.videocardbenchmark.net/midlow_range_gpus.html',
      'http://www.videocardbenchmark.net/low_end_gpus.html'
    ]

    def run!
      @report.output = []

      self.class::URLS.each do |url|
        queue(url) do |response|
          data = PageProcessor.new(response.body).process_page
          data.each do |gpu_data|
            @report.output.push(gpu_data)
          end
        end
      end

      loader.run
    end
  end
end
