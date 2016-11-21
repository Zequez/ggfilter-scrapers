module Scrapers::Steam
  module Game
    describe DataProcessor do
      it 'should copy the attributes from the data hash to the game' do
        game = SteamGame.create name: 'Potato', steam_id: 12345

        data = {
          tags: ['Potato', 'Galaxy', 'Simulator'],
          genre: 'Action',
          dlc_count: 5,
          achievements_count: 80,
          audio_languages: ['English', 'Spanish'],
          subtitles_languages: ['English', 'Spanish', 'Portuguese-Brazil'],
          metacritic: 93,
          esrb_rating: :m,
          videos: [
            "http://cdn.akamai.steamstatic.com/steam/apps/2028092/movie480.webm?t=1352079200",
            "http://cdn.akamai.steamstatic.com/steam/apps/2028471/movie480.webm?t=1377749259"
          ],
          images: [
            "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_26e2d983948edfb911db3e0d2c3679900b4ef9fa.jpg?t=1441392956",
            "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_c6f3fbf3e9f4cb1777462150203a7174608dfcd9.jpg?t=1441392956"
          ],
          summary: 'The potato is in the box',
          early_access: true,
          system_requirements: {
            minimum: {
              processor: 'Intel Potato 900',
              memory: '2GB',
              video_card: 'Nvidia TITAN',
              disk_space: '300 TB'
            },
            recommended: {
              processor: '64 cores Xenon',
              memory: '1TB',
              video_card: 'Nvidia Spaceship SLI x3',
              disk_space: '100 PB'
            }
          },
          players: [:co_op, :single_player],
          controller_support: [:full],
          features: [:steam_achievements, :steam_cloud],
          vr_mode: [:seated],
          vr_platforms: [:rift],
          vr_controllers: [:tracked, :gamepad],
          developer: 'Potato',
          publisher: 'Salad'
        }

        processor = DataProcessor.new(data, game)
        expect(processor.process).to eq game
        expect(game.new_record?).to eq false

        game.save!
        game = SteamGame.first
        expect(game.tags).to eq ['Potato', 'Galaxy', 'Simulator']
        expect(game.genre).to eq 'Action'
        expect(game.dlc_count).to eq 5
        expect(game.achievements_count).to eq 80
        expect(game.audio_languages).to eq ['en', 'es']
        expect(game.subtitles_languages).to eq ['en', 'es', 'pt-BR']
        expect(game.metacritic).to eq 93
        expect(game.esrb_rating).to eq 'm'
        expect(game.videos).to eq [
          "http://cdn.akamai.steamstatic.com/steam/apps/2028092/movie480.webm?t=1352079200",
          "http://cdn.akamai.steamstatic.com/steam/apps/2028471/movie480.webm?t=1377749259"
        ]
        expect(game.images).to eq [
          "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_26e2d983948edfb911db3e0d2c3679900b4ef9fa.jpg?t=1441392956",
          "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_c6f3fbf3e9f4cb1777462150203a7174608dfcd9.jpg?t=1441392956"
        ]
        expect(game.summary).to eq 'The potato is in the box'
        expect(game.early_access).to eq true
        expect(game.system_requirements).to eq({
          minimum: {
            processor: 'Intel Potato 900',
            memory: '2GB',
            video_card: 'Nvidia TITAN',
            disk_space: '300 TB'
          },
          recommended: {
            processor: '64 cores Xenon',
            memory: '1TB',
            video_card: 'Nvidia Spaceship SLI x3',
            disk_space: '100 PB'
          }
        })
        expect(game.players).to match_array [:co_op, :single_player]
        expect(game.controller_support).to eq :full
        expect(game.features).to match_array [:steam_achievements, :steam_cloud]
        expect(game.vr_platforms).to match_array [:rift]
        expect(game.vr_mode).to match_array [:seated]
        expect(game.vr_controllers).to match_array [:tracked, :gamepad]
        expect(game.developer).to eq 'Potato'
        expect(game.publisher).to eq 'Salad'
      end

      it 'should work with non-standard languages' do
        game = SteamGame.create name: 'Potato', steam_id: 12345

        data = {
          audio_languages: ['Simplified Chinese', 'Traditional Chinese'],
          subtitles_languages: [],
          controller_support: []
        }

        processor = DataProcessor.new(data, game)
        processor.process

        expect(game.audio_languages).to eq ['zh-CN', 'zh-TW']
      end
    end
  end
end
