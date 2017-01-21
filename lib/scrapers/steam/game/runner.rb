module Scrapers::Steam::Game
  class Runner < Scrapers::Base::Runner
    def processor; PageProcessor end
    def name; 'steam_game' end

    def self.options
      super.merge({
        game_url: "http://store.steampowered.com/app/%s",
        resources: [],
        headers: {
          'Cookie' => 'birthtime=724320001; mature_content=1; fakeCC=US'
        }
      })
    end

    def urls
      resources.map{ |g| options[:game_url] % g.steam_id }
    end

    def run!
      scrap do |game_data, game|
        data_process game_data, game
      end
    end

    def report_msg
      "#{resources.size} games processed"
    end

    private

    def data_process(data, game)
      processor = DataProcessor.new(data, game)
      game = processor.process
      game.game_scraped_at = Time.now
      game.save!
      log_game(game)
    end

    def log_game(game)
      Scrapers.logger.ln game_log_text(game)
    end
  end
end
