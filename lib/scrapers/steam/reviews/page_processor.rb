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

      # app_id = @url.match(/\/app\/(\d+)/)
      # Scrapers.logger.ln "Loaded #{app_id[1]} page #{current_page}" if app_id

      output
      #
      # if cards.size == 10 and current_page < MAX_PAGES
      #   add(generate_url(current_page + 1)) do |output|
      #     data[:positive] += output[:positive]
      #     data[:negative] += output[:negative]
      #     yield(data)
      #   end
      # else
      #   yield(data)
      # end
    end

    # Quick ugly fix
    # def load(&cb)
    #   @loader.queue_front(@url) do |response|
    #     app_id = @url.match(/\/app\/(\d+)/)
    #     Scrapers.logger.ln "Loaded #{app_id[1]} page #{current_page}" if app_id
    #     process_response(response, &cb)
    #   end
    # end

    # def current_page
    #   @current_page ||= Integer(@url.scan(/p=(\d+)/).flatten.first)
    # end
    #
    # def generate_url(page)
    #   offset = (page-1)*10
    #   @url
    #     .gsub(/userreviewsoffset=\d+/, "userreviewsoffset=#{offset}")
    #     .gsub(/p=\d+/, "p=#{page}")
    # end
  end
end
