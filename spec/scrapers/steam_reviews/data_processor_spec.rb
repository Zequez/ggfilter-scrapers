describe Scrapers::SteamReviews::DataProcessor do
  with_model_extended(
    :Game,
    Scrapers::SteamReviews::GameExtension,
    Scrapers::SteamReviews::Migration::M1
  )

  it 'should copy the attributes from the data hash to the game' do
    game = Game.create

    data = {
      positive: [1.2, 1.3, 1.4, 1.5],
      negative: [0.5, 0.4]
    }

    processor = Scrapers::SteamReviews::DataProcessor.new(data, game)

    expect(processor.process).to eq game

    expect(game.positive_steam_reviews).to eq [1.2, 1.3, 1.4, 1.5]
    expect(game.negative_steam_reviews).to eq [0.5, 0.4]
  end
end
