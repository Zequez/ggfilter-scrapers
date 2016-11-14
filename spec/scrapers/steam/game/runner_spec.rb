module Scrapers::Steam
  module Game
    describe Runner, cassette: true do
      it 'should scrap all the games given' do
        bioshock_infinite = SteamGame.create steam_id: 8870, name: 'Bioshock Infinite'
        dota_2 = SteamGame.create steam_id: 570, name: 'Dota 2'
        runner = Runner.new(resources: [bioshock_infinite, dota_2])
        runner.run
        # Just basic checking
        expect(bioshock_infinite.metacritic).to eq 94
        expect(bioshock_infinite.game_scraped_at).to be_within(1.minute).of(Time.now)
        expect(dota_2.metacritic).to eq 90
        expect(dota_2.game_scraped_at).to be_within(1.minute).of(Time.now)
      end

      it 'should work with this, who knows why' do
        game = SteamGame.create steam_id: 251570, name: '7 Days To Die'
        runner = Runner.new(resources: [game])
        runner.run
        expect(game.positive_reviews_count).to eq 28728
        expect(game.negative_reviews_count).to eq 7166
      end
    end
  end
end
