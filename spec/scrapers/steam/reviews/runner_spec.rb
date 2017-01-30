module Scrapers::Steam
  module Reviews
    describe Runner, cassette: true do
      it 'should scrap all the games given', cassette: 'shadow_thru_and_miko_gakkou' do
        # Shadows of thruth | Miko Gakkou
        runner = Runner.new(steam_ids: [498680, 331290])
        output = runner.run.output
        game1, game2 = output

        output.each{ |g| JSON::Validator.validate! Reviews::SCHEMA, g }

        expect(game1[:positive].size).to be >= 6
        expect(game1[:negative].size).to be >= 3
        expect(game1[:positive]).to eq [4.9, 9.6, 0.9, 0.5, 1.3, 4.8]
        expect(game1[:negative]).to eq [0.8, 3.0, 3.5]
        expect(game2[:positive]).to eq [1.4, 1.5, 0.9, 0.3, 3.0, 4.0, 12.0, 6.0, 0.1, 3.5, 3.8]
        expect(game2[:negative]).to eq [0.7, 0.1, 1.2]
      end

      it 'should scrap multiple pages of reviews', cassette: 'mr_massagy' do
        runner = Runner.new(steam_ids: [511350])
        game = runner.run.output[0]
        expect(game[:negative].size).to eq 1
        expect(game[:positive].size).to eq 35
      end
    end
  end
end
