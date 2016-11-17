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
    def self.generate_url(app_id, options = {})
      options = {
        page: 1,
        order: 'toprated',
        language: 'all',
        search: '',
        per_page: 10
      }.merge(options)

      offset = (options[:page] - 1) * 10

      "http://steamcommunity.com/app/#{app_id}/homecontent/?" + URI.encode_www_form(
        userreviewsoffset: offset,
        p: options[:page],
        workshopitemspage: 2,
        readytouseitemspage: 2,
        mtxitemspage: 2,
        itemspage: 2,
        screenshotspage: 2,
        videospage: 2,
        artpage: 2,
        allguidepage: 2,
        webguidepage: 2,
        integratedguidepage: 2,
        discussionspage: 2,
        numperpage: options[:per_page],
        browsefilter: options[:order],
        l: 'english',
        appHubSubSection: 10,
        filterLanguage: options[:language],
        searchText: options[:search],
        forceanon: 1
      )
    end

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

      return data if @response.body.empty?

      cards = css!('.apphub_Card')

      cards.each do |card|
        next unless card.at_css('.UserReviewCardContent_FlaggedByDeveloper').nil?
        next unless hours_e = card.at_css('.hours')
        next unless hours_m = hours_e.content.match(/^[0-9]+(\.[0-9]+)?/)
        hours = Float(hours_m[0])
        type = card.at_css('img[src*="icon_thumbsUp"]') ? :positive : :negative
        data[type].push hours
      end

      if cards.size == 10 and current_page < MAX_PAGES
        # if current_page == 1
        #   add_to_queue generate_url(current_page + 1)
        #   add_to_queue generate_url(current_page + 2)
        # end

        add(generate_url(current_page + 1)) do |output|
          data[:positive] += output[:positive]
          data[:negative] += output[:negative]
          yield(data)
        end
      else
        yield(data)
      end
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
