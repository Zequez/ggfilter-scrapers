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
    urls_games = Hash[urls.zip(games)]

    @loader = Scrapers::Loader.new(urls, Scrapers::SteamGame::PageProcessor, options[:headers])
    @loader.scrap do |data, url|
      data_process data, urls_games[url]
    end
  end

  private

  def data_process(data, game)
    processor = Scrapers::SteamGame::DataProcessor.new(data, game)
    game = processor.process
    game.save!
    log_game(game)
  end

  def log_game(game)
    log_id = game.steam_id.to_s.ljust(10)
    log_text = "#{log_id} #{game.name}"
    Scrapers.logger.ln log_text
  end
end
