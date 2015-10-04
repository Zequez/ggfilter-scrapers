# Output
# Object of:
#   positive: [
#     hours played by each review
#   ]
#   negative: [
#     hours played by each review
#   ]

class Scrapers::SteamReviews::PageProcessor < Scrapers::BasePageProcessor
  regexp %r{^http://steamcommunity\.com/app/(\d+)/homecontent/\?.*userreviewsoffset=(\d+).*p=(\d+).*$}

  MAX_PAGES = 100

  def inject(all_data)
    all_data ||= { positive: [], negative: [] }
    all_data[:positive] += @data[:positive]
    all_data[:negative] += @data[:negative]
    all_data
  end

  def process_page
    data = {
      positive: [],
      negative: []
    }

    css('.apphub_Card').each do |card|
      next unless card.at_css('.UserReviewCardContent_FlaggedByDeveloper').nil?
      next unless hours_e = card.at_css('.hours')
      next unless hours_m = hours_e.content.match(/^[0-9]+(\.[0-9]+)?/)
      hours = Float(hours_m[0])
      type = card.at_css('img[src*="icon_thumbsUp"]') ? :positive : :negative
      data[type].push hours
    end

    if @initial and @url_data[:reviews_count]
      pages = @url_data[:reviews_count]/10 + 1
      pages = pages > MAX_PAGES ? MAX_PAGES : pages
      (2..pages).each do |page|
        add_to_queue generate_url(page)
      end
    end

    data
  end

  def generate_url(page)
    offset = (page-1)*10
    @url
      .gsub(/userreviewsoffset=\d+/, "userreviewsoffset=#{offset}")
      .gsub(/p=\d+/, "p=#{page}")
  end
end
