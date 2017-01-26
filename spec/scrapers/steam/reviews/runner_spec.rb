module Scrapers::Steam
  module Reviews
    describe Runner, cassette: true do
      it 'should scrap all the games given' do
        # Shadows of thruth | Miko Gakkou
        runner = Runner.new(steam_ids: [498680, 331290])
        data = runner.run.output
        game1 = data[498680]
        game2 = data[331290]

        expect(game1[:positive]).to eq [9.6, 0.5, 0.3]
        expect(game1[:negative]).to eq [0.8, 3.0, 3.5]
        expect(game2[:positive]).to eq [1.4, 1.5, 0.9, 0.3, 3.0, 12.0, 4.0, 6.0, 0.1]
        expect(game2[:negative]).to eq [0.7, 0.1, 1.2]
      end
    end
  end
end
