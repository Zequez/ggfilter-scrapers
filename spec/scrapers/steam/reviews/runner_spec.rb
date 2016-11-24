module Scrapers::Steam
  module Reviews
    describe Runner, cassette: true do
      it 'should scrap all the games given' do
        game1 = SteamGame.create steam_id: 498680 # Shadows of thruth
        game2 = SteamGame.create steam_id: 331290 # Miko Gakkou

        runner = Runner.new(resources: [game1, game2])
        runner.run

        expect(game1.positive_reviews).to eq [9.6, 0.5, 0.3]
        expect(game1.negative_reviews).to eq [0.8, 3.0, 3.5]
        expect(game1.reviews_scraped_at).to be_within(1.minute).of(Time.now)
        expect(game2.positive_reviews).to eq [1.4, 1.5, 0.9, 0.3, 3, 12, 4, 6, 0.1]
        expect(game2.negative_reviews).to eq [0.7, 0.1, 1.2]
        expect(game2.reviews_scraped_at).to be_within(1.minute).of(Time.now)
      end

      it 'should use the #community_hub_id instead of the #steam_id if available' do
        game = SteamGame.create steam_id: 12345, community_hub_id: 54321
        runner = Runner.new(resources: [game])
        expect(runner.urls).to eq [PageProcessor.generate_url(54321)]
      end
    end
  end
end
