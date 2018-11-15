require 'json'

module Scrapers::Steam
  module Reviews
    SCHEMA = JSON.parse(File.read("#{__dir__}/schema.json"))

    class Runner < Scrapers::BasicRunner
      MAX_PAGES = 100

      def initialize(steam_ids: [])
        @steam_ids = steam_ids
        @games_count = 0
        @currently_scraping = {}
        @terminal_size = `tput cols`.to_i
        # @community_hubs_ids = community_hubs_ids
      end

      def run!
        @output_index = {}
        @output = []
        @steam_ids.each do |steam_id|
          queue_new_page(steam_id, 1, generate_url(steam_id, 1))
        end
        loader.run
        @report.output = @output
      end

      def get_game(steam_id)
        @output_index[steam_id] ||= begin
          game = {
            steam_id: steam_id,
            positive: [],
            negative: []
          }
          @output.push game
          game
        end
      end

      def queue_new_page(steam_id, page, url)
        queue(url, front: page > 1) do |response|
          game = get_game(steam_id)

          page_data = PageProcessor.new(response.body).process_page
          if page_data
            game[:positive].concat page_data[:positive]
            game[:negative].concat page_data[:negative]
          end

          if page_data && page_data[:next_page] && page < MAX_PAGES
            @currently_scraping[steam_id] = page
            log_status
            queue_new_page(steam_id, page + 1, page_data[:next_page])
          else
            @currently_scraping.delete(steam_id)
            @games_count += 1
            log_game(game)
          end
        end
      end

      def scraper_report
        "#{@steam_ids.size} games reviews scraped"
      end

      private

      def log_status
        remaining = "| Remaining: #{@games_count}/#{@steam_ids.size}"
        text = @currently_scraping
          .each_pair.map{ |steam_id, page| "#{steam_id}: #{page.to_s.rjust(2)}" }
          .join(' | ')
        Scrapers.logger.print "#{text} | #{remaining}".ljust(@terminal_size - 1) + "\r"
      end

      def log_game(game)
        positive = game[:positive].size
        negative = game[:negative].size

        Scrapers.logger.ln "\n#{game[:steam_id]} done! #{positive}/#{negative} reviews"
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

        "https://steamcommunity.com/app/#{steam_id}/homecontent/?" + URI.encode_www_form(
          userreviewsoffset: offset,
          p: page,
          workshopitemspage: page,
          readytouseitemspage: page,
          mtxitemspage: page,
          itemspage: page,
          screenshotspage: page,
          videospage: page,
          artpage: page,
          allguidepage: page,
          webguidepage: page,
          integratedguidepage: page,
          discussionspage: page,
          numperpage: options[:per_page],
          browsefilter: options[:order],
          appid: steam_id,
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
