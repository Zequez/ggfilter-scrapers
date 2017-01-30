module Scrapers::Steam::Reviews
  class PageProcessor < Scrapers::Base::PageProcessor
    MAX_PAGES = 100

    def process_page
      if @html.empty?
        return nil
      end

      output = {
        positive: [],
        negative: []
      }

      cards = css!('.apphub_Card')
      cards.each do |card|
        next unless card.at_css('.UserReviewCardContent_FlaggedByDeveloper').nil?
        next unless hours_e = card.at_css('.hours')
        next unless hours_m = hours_e.content.match(/^[0-9]+(\.[0-9]+)?/)
        hours = Float(hours_m[0])
        type = card.at_css('img[src*="icon_thumbsUp"]') ? :positive : :negative
        output[type].push hours
      end

      if css('form').first
        next_page_query = css('form input')
          .map{ |ie| [ie.attr('name'), ie.attr('value')] }
        next_page_url = css('form').first.attr('action')
        query_hash = Hash[next_page_query]
        if query_hash['userreviewsoffset'].to_i % 10 == 0
          output[:next_page] =
            next_page_url + '?' + URI.encode_www_form(Hash[next_page_query])
        end
      end

      output
    end
  end
end
