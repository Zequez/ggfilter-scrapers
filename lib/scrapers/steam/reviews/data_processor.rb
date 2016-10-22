module Scrapers::Steam::Reviews
  class DataProcessor
    def initialize(data, game)
      @data = data
      @game = game
      @errors = []
    end

    attr_reader :errors

    def process
      data = {
        positive_reviews: @data[:positive],
        negative_reviews: @data[:negative]
      }
      @game.assign_attributes(data)
      @game
    end
  end
end
