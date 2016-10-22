module Scrapers
  module Steam
    module List
      class DataProcessor
        def initialize(data, game)
          @data = data
          @game = game || SteamGame.new
          @errors = []
        end

        attr_reader :errors

        def process
          @game.steam_id      = @data[:id]
          @game.name          = @data[:name]
          @game.price         = @data[:price]
          @game.sale_price    = @data[:sale_price]
          @game.released_at   = @data[:released_at]
          @game.platforms     = @data[:platforms]
          @game.reviews_count = @data[:reviews_count]
          @game.reviews_ratio = @data[:reviews_ratio]
          @game.thumbnail     = @data[:thumbnail]
          @game
        end
      end
    end
  end
end