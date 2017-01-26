module Scrapers::Steam
  module List
    describe Runner, cassette: true, type: :steam_list do
      it 'should scrap all games' do
        runner = Runner.new(url: steam_list_url('k'))
        games = runner.run.output

        expect(games.size).to eq 249
        game = games.find{ |g| g[:name] == 'XCOM: Enemy Unknown' }

        expect(game).to_not eq nil
        expect(game[:platforms]).to match_array [:mac, :win, :linux]
        expect(game[:steam_published_at]).to be_within(1.day).of Time.parse('8 Oct, 2012')
        expect(game[:reviews_count]).to be_within(100).of 30195
        expect(game[:reviews_ratio]).to eq 95
        expect(game[:thumbnail]).to eq 'http://cdn.akamai.steamstatic.com/steam/apps/200510/capsule_sm_120.jpg?t=1447366133'
        expect(game[:steam_id]).to eq 200510
      end
    end
  end
end
