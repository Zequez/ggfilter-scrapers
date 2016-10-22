module Scrapers::Steam::Game
  class Runner < Scrapers::Base::Runner
    def self.options
      {
        game_url: "http://store.steampowered.com/app/%s",
        games: [],
        headers: {
          'Cookie' => 'birthtime=724320001; fakeCC=US'
        },
        continue_with_errors: false
      }
    end

    def run!
      game_url = options[:game_url]
      games = options[:games]

      Scrapers.logger.info "#{games.size} to scrap!"

      urls = games.map{ |g| game_url % g.steam_id }

      @loader = Scrapers::Loader.new(
        PageProcessor,
        urls,
        nil,
        games,
        continue_with_errors: options[:continue_with_errors],
        headers: options[:headers]
      )
      @loader.scrap do |scrap_request|
        data_process scrap_request.output, scrap_request.resource
      end
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
