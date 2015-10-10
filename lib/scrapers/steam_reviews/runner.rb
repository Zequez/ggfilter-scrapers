class Scrapers::SteamReviews::Runner < Scrapers::BaseRunner
  def self.options
    {
      games: [],
      reviews_url: 'http://steamcommunity.com/app/%s/homecontent/?l=english&userreviewsoffset=0&p=1&itemspage=2&screenshotspage=2&videospage=2&artpage=2&allguidepage=2&webguidepage=2&integratedguidepage=2&discussionspage=2&appHubSubSection=10&browsefilter=toprated&filterLanguage=default&searchText=',
      continue_with_errors: false
    }
  end

  def run!
    reviews_url = options[:reviews_url]
    games = options[:games]

    urls = games.map{ |g| reviews_url % g.steam_id }

    @loader = Scrapers::Loader.new(
      Scrapers::SteamReviews::PageProcessor,
      urls,
      nil,
      games,
      continue_with_errors: options[:continue_with_errors]
    )
    @loader.scrap do |scrap_request|
      if scrap_request.root.all_finished?
        game = scrap_request.resource
        data = scrap_request.root.consolidated_output
        data_process(data, game)
      end
    end
  end

  private

  def data_process(data, game)
    processor = Scrapers::SteamReviews::DataProcessor.new(data, game)
    game = processor.process
    game.steam_reviews_scraped_at = Time.now
    game.save!
    log_game(game)
  end

  def log_game(game)
    positive = game.positive_steam_reviews.size
    negative = game.negative_steam_reviews.size
    Scrapers.logger.ln "#{game_log_text(game)} Reviews: [#{positive}/#{negative}]"
  end
end
