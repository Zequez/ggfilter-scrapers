module Scrapers::Steam
  module Reviews
    describe DataProcessor do
      it 'should copy the attributes from the data hash to the game' do
        game = SteamGame.create name: 'rsa', steam_id: 1235

        data = {
          positive: [1.2, 1.3, 1.4, 1.5],
          negative: [0.5, 0.4]
        }

        processor = DataProcessor.new(data, game)

        expect(processor.process).to eq game

        expect(game.positive_reviews).to eq [1.2, 1.3, 1.4, 1.5]
        expect(game.negative_reviews).to eq [0.5, 0.4]
      end
    end
  end
end
