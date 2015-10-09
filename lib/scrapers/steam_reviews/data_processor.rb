class Scrapers::SteamReviews::DataProcessor
  def initialize(data, game)
    @data = data
    @game = game
    @errors = []
  end

  attr_reader :errors

  def process
    data = {
      positive_steam_reviews: @data[:positive],
      negative_steam_reviews: @data[:negative]
    }
    @game.assign_attributes(data)
    @game
  end
end
