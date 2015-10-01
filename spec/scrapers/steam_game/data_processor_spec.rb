describe Scrapers::SteamGame::DataProcessor do
  klass = Scrapers::SteamGame::DataProcessor
  # 
  # it 'should copy the attributes from the data hash to the game' do
  #   game = create :game
  #   data = {
  #     tags: ['Potato', 'Galaxy', 'Simulator'],
  #     genre: 'Action',
  #     dlc_count: 5,
  #     steam_achievements_count: 80,
  #     audio_languages: ['English', 'Spanish'],
  #     subtitles_languages: ['English', 'Spanish', 'Portuguese-Brazil'],
  #     metacritic: 93,
  #     esrb_rating: :m,
  #     videos: [
  #       "http://cdn.akamai.steamstatic.com/steam/apps/2028092/movie480.webm?t=1352079200",
  #       "http://cdn.akamai.steamstatic.com/steam/apps/2028471/movie480.webm?t=1377749259"
  #     ],
  #     images: [
  #       "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_26e2d983948edfb911db3e0d2c3679900b4ef9fa.jpg?t=1441392956",
  #       "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_c6f3fbf3e9f4cb1777462150203a7174608dfcd9.jpg?t=1441392956"
  #     ],
  #     summary: 'The potato is in the box',
  #     early_access: true,
  #     system_requirements: {
  #       minimum: {
  #         processor: 'Intel Potato 900',
  #         memory: '2GB',
  #         video_card: 'Nvidia TITAN',
  #         disk_space: '300 TB'
  #       },
  #       recommended: {
  #         processor: '64 cores Xenon',
  #         memory: '1TB',
  #         video_card: 'Nvidia Spaceship SLI x3',
  #         disk_space: '100 PB'
  #       }
  #     },
  #     players: [:co_op, :single_player],
  #     controller_support: [:full],
  #     features: [:steam_achievements, :vr_support, :steam_cloud]
  #   }
  # end
end
