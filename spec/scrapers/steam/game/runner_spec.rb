module Scrapers::Steam
  module Game
    describe Runner, cassette: true do
      it 'should scrap all the games given' do
        # Bioshock Infinite && Dota 2
        runner = Runner.new(steam_ids: [8870, 570])

        report = runner.run
        games = report.output

        games.each{ |g| JSON::Validator.validate! Game::SCHEMA, g }

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

      it 'should work with the processor returning empty' do
        runner = Runner.new(steam_ids: [8870])

        pp = double('PageProcessor')
        expect(Game::PageProcessor).to receive(:new).and_return pp
        expect(pp).to receive(:process_page).and_return nil

        report = runner.run

        expect(report.warnings.size).to eq 1
      end

      it 'should add a warning when a game redirects' do
        runner = Runner.new(steam_ids: [8870])

        Typhoeus.stub("http://store.steampowered.com/app/8870")
          .and_return(Typhoeus::Response.new(code: 304, body: '', headers: {
            'Location' => 'http://store.steampowered.com'
          }))

        expect(Game::PageProcessor).to_not receive(:new)

        report = runner.run

        expect(report.warnings.size).to eq 1
        expect(report.warnings[0]).to match(/redirect/)
      end
    end
  end
end
