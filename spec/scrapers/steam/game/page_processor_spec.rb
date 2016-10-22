describe Scrapers::Steam::Game::PageProcessor, cassette: true do
  def processor_class; Scrapers::Steam::Game::PageProcessor end

  def steam_game_url(app_id)
    "http://store.steampowered.com/app/#{app_id}"
  end

  def self.game_cassette_subject(app_id, name = 'game')
    before_all_cassette(name) do
      url = steam_game_url(app_id)
      @result = scrap(url, 'Cookie' => 'birthtime=724320001; fakeCC=US')
    end
    subject{ @result }
  end

  describe 'URL detection' do
    it 'should detect the Steam search result URLs' do
      url = steam_game_url(1)
      expect(url).to match processor_class.regexp
    end

    it 'should not detect non-steam search result URLs' do
      url = "http://store.steampowered.com/banana/123456"
      expect(url).to_not match processor_class.regexp
    end
  end

  describe 'loading a regular game like Bioshock Infinite' do
    game_cassette_subject(8870, 'bioshock_infinite')

    its([:genre]){                    is_expected.to eq 'Action' }
    its([:dlc_count]){                is_expected.to eq 5 }
    its([:achievements_count]){       is_expected.to eq 80 }
    its([:metacritic]){               is_expected.to eq 94 }
    its([:esrb_rating]){              is_expected.to eq :m }
    its([:early_access]){             is_expected.to eq false }
    its([:positive_reviews_count]){   is_expected.to eq 53994 }
    its([:negative_reviews_count]){   is_expected.to eq 2647 }

    its([:tags]){ are_expected.to eq([
      "FPS",
      "Action",
      "Story Rich",
      "Singleplayer",
      "Steampunk",
      "Atmospheric",
      "Shooter",
      "First-Person",
      "Alternate History",
      "Adventure",
      "Great Soundtrack",
      "Dystopian",
      "Sci-fi",
      "Time Travel",
      "Fantasy",
      "Linear",
      "Gore",
      "RPG",
      "Political",
      "Controller"
    ])}

    its([:audio_languages]){ are_expected.to match_array([
      "English",
      "French",
      "German",
      "Italian",
      "Spanish",
      "Japanese"
    ])}

    its([:subtitles_languages]){ are_expected.to match_array([
      "English",
      "French",
      "German",
      "Italian",
      "Spanish",
      "Polish",
      "Portuguese-Brazil",
      "Russian",
      "Japanese",
      "Korean"
    ])}

    it{ expect(@result[:videos].map{|v| v.sub(/\?t=\d+$/, '')}).to eq([
      "http://cdn.akamai.steamstatic.com/steam/apps/2028092/movie480.webm",
      "http://cdn.akamai.steamstatic.com/steam/apps/2028471/movie480.webm",
      "http://cdn.akamai.steamstatic.com/steam/apps/2028345/movie480.webm",
      "http://cdn.akamai.steamstatic.com/steam/apps/2028377/movie480.webm"
    ])}

    it{ expect(@result[:images].map{|v| v.sub(/\?t=\d+$/, '')}).to eq([
      "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_26e2d983948edfb911db3e0d2c3679900b4ef9fa.jpg",
      "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_c6f3fbf3e9f4cb1777462150203a7174608dfcd9.jpg",
      "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_dc76723504ce89c1ed1f66fd468682ba76548c32.jpg",
      "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_37f25110f8d76335ddbc29a381bc6961e209acf6.jpg",
      "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_d45294620026ff41f7e6b8610c6d60e13645fbf3.jpg",
      "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_fd6f5de55332f6c3cd119a01a9e017e840765c0e.jpg",
      "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_3a364ffdcd2c1eeb3957435c624fc7c383d8cb69.jpg",
      "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_4616da02724c2beaa8afc74a501929d27a65542a.jpg",
      "http://cdn.akamai.steamstatic.com/steam/apps/8870/ss_e98deaf0e334206b84c2462276aee98107fa20d0.jpg"
    ])}

    its([:summary]){                  is_expected.to eq(
      <<-EOS.squeeze(' ').strip.gsub("\n", '')
      Indebted to the wrong people, with his life on the line,
      veteran of the U.S. Cavalry and now hired gun, Booker DeWitt
      has only one opportunity to wipe his slate clean. He must rescue
      Elizabeth, a mysterious girl imprisoned since childhood and
      locked up in the flying city of Columbia.
      EOS
    )}

    its([:system_requirements]){ are_expected.to eq({
      minimum: {
        processor: 'Intel Core 2 DUO 2.4 GHz / AMD Athlon X2 2.7 GHz',
        memory: '2GB',
        video_card: 'DirectX10 Compatible ATI Radeon HD 3870 / NVIDIA 8800 GT / Intel HD 3000 Integrated Graphics',
        disk_space: '20 GB free'
      },
      recommended: {
        processor: 'Quad Core Processor',
        memory: '4GB',
        video_card: 'DirectX11 Compatible, AMD Radeon HD 6950 / NVIDIA GeForce GTX 560',
        disk_space: '30 GB free'
      }
    })}

    its([:players]){ is_expected.to match_array [:single_player] }
    its([:controller_support]){ is_expected.to match_array [:full] }
    its([:features]){ are_expected.to match_array([
      :steam_achievements,
      :steam_trading_cards,
      :steam_cloud
    ])}
  end

  describe 'game with VR support && no recommended requirements && !metacritic && !esrb' do
    game_cassette_subject(396030, 'in_cell_vr')

    its([:features]){ are_expected.to match_array([
      :steam_achievements,
      :steam_trading_cards
    ])}

    its([:vr_platforms]){ are_expected.to match_array([
      :vive,
      :rift
    ])}

    its([:vr_mode]){ are_expected.to match_array([
      :seated
    ])}

    its([:metacritic]){ is_expected.to eq nil }
    its([:esrb]){ is_expected.to eq nil }

    its([:system_requirements]){ are_expected.to eq({
      minimum: {
        processor: 'Intel or AMD Dual-Core CPU with 2.8 GHz',
        memory: '4 GB RAM',
        video_card: 'No VR Mode: NVIDIA GeForce GTX 560 or AMD Radeon HD6900  | VR Mode: NVIDIA GeForce GTX 750 Ti or AMD Radeon R9 270 (FullHD resolution)',
        disk_space: '1500 MB available space'
      },
      recommended: {
        processor: nil,
        memory: nil,
        video_card: nil,
        disk_space: nil
      }
    })}
  end

  describe 'game with advanced VR support' do
    game_cassette_subject(471710, 'rec_room')

    its([:vr_platforms]){ are_expected.to match_array([
      :vive
    ])}

    its([:vr_controllers]){ are_expected.to match_array([
      :tracked
    ])}

    its([:vr_mode]){ are_expected.to match_array([
      :standing,
      :room_scale
    ])}
  end

  describe 'game with multiplayer && VAC && co-op && !achievements && !controller support' do
    game_cassette_subject(570, 'dota_2')

    its([:achievements_count]){ are_expected.to eq 0 }

    its([:features]){ are_expected.to match_array([
      :steam_workshop,
      :valve_anti_cheat,
      :steam_trading_cards
    ])}

    its([:players]){ are_expected.to match_array([:multi_player, :co_op])}

    its([:controller_support]){ is_expected.to match_array [] }
  end

  describe 'game with partial controller support' do
    game_cassette_subject(413150, 'stardew_valley')

    its([:controller_support]){ is_expected.to match_array [:partial] }
  end

  describe 'game with early access' do
    game_cassette_subject(264710, 'subnautica')

    its([:early_access]){ is_expected.to eq true }
  end

  describe 'edge case system requirements' do
    game_cassette_subject(2710, 'act_of_war_direct_action')

    its([:system_requirements]){ are_expected.to eq({
      minimum: {
        processor: 'Pentium 4 1.5 GHz or equivalent (3.0 GHz recommended)',
        memory: '256 MB RAM (512 MB recommended)',
        video_card: '64 MB Hardware T&amp;L-compatible video card (256 MB recommended)',
        disk_space: '3 GB free HD space'
      },
      recommended: {
        processor: nil,
        memory: nil,
        video_card: nil,
        disk_space: nil
      }
    })}
  end

  describe 'edge case steam achievements?' do
    game_cassette_subject(388800, 'azure_striker_gunvolt')

    its([:achievements_count]){ is_expected.to eq 25 }
  end

  describe 'another edge case with system requirements' do
    game_cassette_subject(209160, 'call_of_duty_ghosts')

    its([:system_requirements]){ are_expected.to eq({
      minimum: {
        processor: 'Intel® Core™ 2 Duo E8200 2.66 GHZ / AMD Phenom™ X3 8750 2.4 GHZ or better',
        memory: '6 GB RAM',
        video_card: 'NVIDIA® GeForce™ GTS 450 / ATI® Radeon™ HD 5870 or better',
        disk_space: '40 GB HD space'
      },
      recommended: {
        processor: 'Intel® Core™ i5 – 680 @ 3.6GHz',
        memory: '8 GB RAM',
        video_card: 'NVIDIA® GeForce™ GTX 760 @ 4GB',
        disk_space: '40 GB HD space'
      }
    })}
  end
end
