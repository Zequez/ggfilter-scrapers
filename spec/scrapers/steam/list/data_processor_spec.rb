module Scrapers::Steam
  module List
    describe DataProcessor do
      it 'should copy the attributes from the data hash to the game' do
        game = SteamGame.create steam_id: 12345

        data = {
          id: 1234,
          name: 'Potato',
          price: 123,
          sale_price: 50,
          released_at: 1.week.ago,
          text_release_date: 'This fall!',
          platforms: [:win, :mac, :linux],
          reviews_count: 1111,
          reviews_ratio: 95,
          thumbnail: 'http://imgur.com/rsarsa'
        }

        processor = DataProcessor.new(data, game)
        expect(processor.process).to eq game

        expect(game.steam_id).to eq 1234
        expect(game.name).to eq 'Potato'
        expect(game.price).to eq 123
        expect(game.sale_price).to eq 50
        expect(game.released_at).to be_within(1.minute).of(1.week.ago)
        expect(game.text_release_date).to eq 'This fall!'
        expect(game.platforms).to match_array [:win, :mac, :linux]
        expect(game.reviews_count).to eq 1111
        expect(game.reviews_ratio).to eq 95
        expect(game.thumbnail).to eq 'http://imgur.com/rsarsa'

        expect(game.new_record?).to eq false
      end

      it "should build a new Game if it's nil" do
        data = {
          id: 1234,
          name: 'Potato',
          price: 123,
          sale_price: 50,
          released_at: 1.week.ago,
          text_release_date: 'This fall!',
          platforms: [:win, :mac, :linux],
          reviews_count: 1111,
          reviews_ratio: 95,
          thumbnail: 'http://imgur.com/rsarsa'
        }

        processor = DataProcessor.new(data, nil)
        game = processor.process

        expect(game.steam_id).to eq 1234
        expect(game.name).to eq 'Potato'
        expect(game.price).to eq 123
        expect(game.sale_price).to eq 50
        expect(game.released_at).to be_within(1.minute).of(1.week.ago)
        expect(game.text_release_date).to eq 'This fall!'
        expect(game.platforms).to match_array [:win, :mac, :linux]
        expect(game.reviews_count).to eq 1111
        expect(game.reviews_ratio).to eq 95
        expect(game.thumbnail).to eq 'http://imgur.com/rsarsa'

        expect(game.new_record?).to eq true
      end
    end
  end
end
