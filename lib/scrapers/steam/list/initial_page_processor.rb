module Scrapers::Steam::List
  class InitialPageProcessor < Scrapers::Base::PageProcessor
    def initialize(body, url)
      super body
      @url = url
    end

    def process_page
      css!('#search_result_container')

      pagination = css('.search_pagination_right')
      last_page_e = pagination.search('a:not(.pagebtn)').last
      if last_page_e
        last_page_link = last_page_e['href'].sub(%r{/search/\?}, '/search/results?')
        pages = Integer(last_page_link.scan(/page=(\d+)/).flatten.first)
      else
        pages = 1
      end

      urls = []

      (1..pages).each do |n|
        urls.push @url.sub(/page=(\d+)/, "page=#{n}")
      end

      urls
    end
  end
end
