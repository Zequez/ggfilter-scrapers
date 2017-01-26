module Scrapers::Steam
  module Game
    describe Runner, cassette: true do
      it 'should scrap all the games given' do
        # Bioshock Infinite && Dota 2
        runner = Runner.new(steam_ids: [8870, 570])

        report = runner.run
        games = report.output

        expect(games.size).to eq 2
        expect(games[0][:metacritic]).to eq 94
        expect(games[1][:metacritic]).to eq 90
      end

      it 'should work with this, who knows why' do
        # 7 Days To Die
        runner = Runner.new(steam_ids: [251570])
        game = runner.run.output[0]
        expect(game[:positive_reviews_count]).to eq 28728
        expect(game[:negative_reviews_count]).to eq 7166
      end
    end
  end
end
