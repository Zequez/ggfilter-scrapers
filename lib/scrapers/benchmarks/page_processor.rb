module Scrapers::Benchmarks
  class PageProcessor < Scrapers::Base::PageProcessor
    regexp %r{http://www.videocardbenchmark.net/([a-z0-9_-]+).html}

    def process_page
      gpus = []

      css('#mark table.chart tr')[1..-2].each do |tr|
        gpu = {}
        gpu[:name] = tr.search('.chart:first-child a').text
        gpu[:value] = tr.search('.value div').text.gsub(/,/, '').to_i
        gpus.push gpu
      end

      gpus
    end
  end
end
