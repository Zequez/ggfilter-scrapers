class Scrapers::SteamGame::Runner < Scrapers::BaseRunner
  def self.options
    {
      game_url: "http://store.steampowered.com/app/%s",
      games: [],
      headers: {
        'Cookie' => 'birthtime=724320001; fakeCC=US'
      }
    }
  end

  def run
    Scrapers.logger.info 'SteamGame scraper running'

    game_url = options[:game_url]
    games = options[:games]

    urls = games.map{ |g| game_url % g.steam_id }

    @loader = Scrapers::Loader.new(Scrapers::SteamGame::PageProcessor, urls, nil, games, headers: options[:headers])
    @loader.scrap do |scrap_request|
      data_process scrap_request.output, scrap_request.resource
    end
  end

  private

  def data_process(data, game)
    processor = Scrapers::SteamGame::DataProcessor.new(data, game)
    game = processor.process
    game.steam_game_scraped_at = Time.now
    game.save!
    log_game(game)
  end

  def log_game(game)
    log_id = game.steam_id.to_s.ljust(10)
    log_text = "#{log_id} #{game.name}"
    Scrapers.logger.ln log_text
  end
end
