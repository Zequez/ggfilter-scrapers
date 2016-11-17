module Scrapers::Benchmarks
  class PageProcessor < Scrapers::Base::PageProcessor
    def process_page
      gpus = []

      css('#mark table.chart tr')[1..-2].each do |tr|
        name = tr.search('.chart:first-child a').text
        if not (name =~ /\+/)
          gpu = {}
          gpu[:name] = name
          gpu[:value] = tr.search('.value div').text.gsub(/,/, '').to_i
          gpus.push gpu
        end
      end

      yield gpus
    end
  end
end
