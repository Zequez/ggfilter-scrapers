module Scrapers::Steam
  module Reviews
    class Runner < Scrapers::Base::Runner
      def processor; PageProcessor end
      def name; 'steam_reviews' end

      def self.options
        super.merge({
          resources: []
        })
      end

      def urls
        resources.map{ |g| processor.generate_url(g.community_hub_id || g.steam_id) }
      end

      def run!
        scrap do |data, resource|
          data_process(data, resource)
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
