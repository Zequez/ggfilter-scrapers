module Scrapers::Steam
  module Reviews
    class Runner < Scrapers::Base::Runner
      def processor; PageProcessor end

      def self.options
        super.merge({
          resources: [],
          reviews_url: 'http://steamcommunity.com/app/%s/homecontent/?l=english&userreviewsoffset=0&p=1&itemspage=2&screenshotspage=2&videospage=2&artpage=2&allguidepage=2&webguidepage=2&integratedguidepage=2&discussionspage=2&appHubSubSection=10&browsefilter=toprated&filterLanguage=all&searchText='
        })
      end

      def urls
        resources.map{ |g| options[:reviews_url] % g.steam_id }
      end

      def run!
        scrap(yield_type: :group) do |scrap_request, resource|
          data_process(scrap_request.consolidated_output, resource)
        end
      end

      private

      def data_process(data, game)
        processor = DataProcessor.new(data, game)
        game = processor.process
        game.reviews_scraped_at = Time.now
        game.save!
        log_game(game)
      end

      def log_game(game)
        positive = game.positive_reviews.size
        negative = game.negative_reviews.size
        Scrapers.logger.ln "#{game_log_text(game)} Reviews: [#{positive}/#{negative}]"
      end
    end
  end
end
