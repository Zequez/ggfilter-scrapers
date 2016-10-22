# Input
# reviews_count: Integer
# Output
# Object of:
#   positive: [
#     hours played by each review
#   ]
#   negative: [
#     hours played by each review
#   ]

module Scrapers::Steam::Reviews
  class PageProcessor < Scrapers::Base::PageProcessor
    regexp %r{^http://steamcommunity\.com/app/(\d+)/homecontent/\?.*userreviewsoffset=(\d+).*p=(\d+).*$}

    MAX_PAGES = 100

    def self.inject(all_data, data)
      all_data ||= { positive: [], negative: [] }
      all_data[:positive] += data[:positive]
      all_data[:negative] += data[:negative]
      all_data
    end

    def process_page
      data = {
        positive: [],
        negative: []
      }

      cards = css('.apphub_Card')

      cards.each do |card|
        next unless card.at_css('.UserReviewCardContent_FlaggedByDeveloper').nil?
        next unless hours_e = card.at_css('.hours')
        next unless hours_m = hours_e.content.match(/^[0-9]+(\.[0-9]+)?/)
        hours = Float(hours_m[0])
        type = card.at_css('img[src*="icon_thumbsUp"]') ? :positive : :negative
        data[type].push hours
      end

      if cards.size == 10 and current_page < MAX_PAGES
        if current_page == 1
          add_to_queue generate_url(current_page + 1)
          add_to_queue generate_url(current_page + 2)
        end

        add_to_queue generate_url(current_page + 3)
      end

      data
    end

    def current_page
      @current_page ||= Integer(@url.scan(/p=(\d+)/).flatten.first)
    end

    def generate_url(page)
      offset = (page-1)*10
      @url
        .gsub(/userreviewsoffset=\d+/, "userreviewsoffset=#{offset}")
        .gsub(/p=\d+/, "p=#{page}")
    end
  end
end
