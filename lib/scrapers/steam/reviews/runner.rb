module Scrapers::Steam
  module Reviews
    class Runner < Scrapers::BasicRunner
      MAX_PAGES = 100

      def initialize(steam_ids: [])
        @steam_ids = steam_ids
        # @community_hubs_ids = community_hubs_ids
      end

      def run!
        @output = {}
        @steam_ids.each do |steam_id|
          queue_new_page(steam_id, 1)
        end
        loader.run
        @report.output = @output
      end

      def queue_new_page(steam_id, page)
        url = generate_url(steam_id, page)
        queue(url, front: page > 1) do |response|
          @output[steam_id] ||= { positive: [], negative: [] }
          page_data = PageProcessor.new(response.body).process_page
          if page_data && page < MAX_PAGES
            log_page(steam_id, page)
            @output[steam_id][:positive].concat page_data[:positive]
            @output[steam_id][:negative].concat page_data[:negative]
            queue_new_page(steam_id, page + 1)
          else
            log_game(steam_id, @output[steam_id])
          end
        end
      end

      def scraper_report
        "#{@steam_ids.size} games reviews scraped"
      end

      private

      def log_page(steam_id, page)
        Scrapers.logger.ln "#{steam_id} Reviews page #{page}"
      end

      def log_game(steam_id, output)
        positive = output[:positive].size
        negative = output[:negative].size

        Scrapers.logger.ln "#{steam_id} Reviews: [#{positive}/#{negative}]"
      end

      def generate_url(*args)
        self.class.generate_url(*args)
      end

      def self.generate_url(steam_id, page = 1, options = {})
        options = {
          order: 'toprated',
          language: 'all',
          search: '',
          per_page: 10
        }.merge(options)

        offset = (page - 1) * 10

        "http://steamcommunity.com/app/#{steam_id}/homecontent/?" + URI.encode_www_form(
          userreviewsoffset: offset,
          p: page,
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
    end
  end
end
