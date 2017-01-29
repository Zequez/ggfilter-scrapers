describe Scrapers::Steam::Game::PageProcessor, cassette: true do
  def processor_class; Scrapers::Steam::Game::PageProcessor end

  def steam_game_url(app_id)
    "http://store.steampowered.com/app/#{app_id}"
  end

  def self.cassette_subject(app_id, name = 'game')
    before_all_cassette(name) do
      url = steam_game_url(app_id)
      response = Typhoeus.get(url, {
        headers: {
          'Cookie' => 'birthtime=724320001; fakeCC=US'
        }
      })
      @result = Scrapers::Steam::Game::PageProcessor.new(response.body).process_page
      JSON::Validator.validate! Scrapers::Steam::Game::SCHEMA, @result if @result
    end
    subject{ @result }
  end

  describe 'error handling' do
    it 'should raise an error if the page is invalid' do
      expect { Scrapers::Steam::Game::PageProcessor.new('<html></html>').process_page }
      .to raise_error(/Could not find/i)
    end

    describe 'game unavailable in the region' do
      cassette_subject(386180, 'unavailable_game_in_the_region')

      it 'should be quietly ignored, because steams return 200-success header' do
        expect(@result).to eq nil
      end
    end
  end

  describe 'loading a regular game like Bioshock Infinite' do
    cassette_subject(8870, 'bioshock_infinite')

    its([:genre]){                    is_expected.to eq 'Action' }
    its([:dlc_count]){                is_expected.to eq 5 }
    its([:achievements_count]){       is_expected.to eq 80 }
    its([:metacritic]){               is_expected.to eq 94 }
    its([:esrb_rating]){              is_expected.to eq :m }
    its([:early_access]){             is_expected.to eq false }
    its([:positive_reviews_count]){   is_expected.to be >= 60391 }
    its([:negative_reviews_count]){   is_expected.to be >= 2758 }
    its([:community_hub_id]) {        is_expected.to eq 8870 }

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

    it{
      expect(@result[:videos][0]).to match(/2028092\/movie480\.webm/)
      expect(@result[:videos][1]).to match(/2028471\/movie480\.webm/)
      expect(@result[:videos][2]).to match(/2028345\/movie480\.webm/)
      expect(@result[:videos][3]).to match(/2028377\/movie480\.webm/)
    }

    it{
      ["26e2d983948edfb911db3e0d2c3679900b4ef9fa.jpg",
      "c6f3fbf3e9f4cb1777462150203a7174608dfcd9.jpg",
      "dc76723504ce89c1ed1f66fd468682ba76548c32.jpg",
      "37f25110f8d76335ddbc29a381bc6961e209acf6.jpg",
      "d45294620026ff41f7e6b8610c6d60e13645fbf3.jpg",
      "fd6f5de55332f6c3cd119a01a9e017e840765c0e.jpg",
      "3a364ffdcd2c1eeb3957435c624fc7c383d8cb69.jpg",
      "4616da02724c2beaa8afc74a501929d27a65542a.jpg",
      "e98deaf0e334206b84c2462276aee98107fa20d0.jpg"].each_with_index do |img, i|
        expect(@result[:images][i]).to match(img)
      end
    }

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
    its([:controller_support]){ is_expected.to eq :full }
    its([:features]){ are_expected.to match_array([
      :steam_achievements,
      :steam_trading_cards,
      :steam_cloud
    ])}
    its([:vr_only]){ is_expected.to eq false }

    its([:developer]) { is_expected.to eq 'Irrational Games' }
    its([:publisher]) { is_expected.to eq '2K Games' }
  end

  describe 'game with VR support && no recommended requirements && !metacritic && !esrb' do
    cassette_subject(396030, 'in_cell_vr')

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

    its([:developer]) { is_expected.to eq 'Nival VR' }
    its([:publisher]) { is_expected.to eq 'Nival' }
  end

  describe 'game with advanced VR support' do
    cassette_subject(471710, 'rec_room')

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
    cassette_subject(570, 'dota_2')

    its([:achievements_count]){ are_expected.to eq 0 }

    its([:features]){ are_expected.to match_array([
      :steam_workshop,
      :valve_anti_cheat,
      :steam_trading_cards
    ])}

    its([:players]){ are_expected.to match_array([:multi_player, :co_op])}

    its([:controller_support]){ is_expected.to eq :no }
  end

  describe 'game with partial controller support' do
    cassette_subject(413150, 'stardew_valley')

    its([:controller_support]){ is_expected.to eq :partial }
  end

  describe 'game with early access' do
    cassette_subject(264710, 'subnautica')

    its([:early_access]){ is_expected.to eq true }
  end

  describe 'edge case system requirements' do
    cassette_subject(2710, 'act_of_war_direct_action')

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
    cassette_subject(388800, 'azure_striker_gunvolt')

    its([:achievements_count]){ is_expected.to eq 25 }
  end

  describe 'another edge case with system requirements' do
    cassette_subject(209160, 'call_of_duty_ghosts')

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

  describe 'game without reviews' do
    cassette_subject(381000, '6_nights')

    its([:positive_reviews_count]){ is_expected.to eq 0 }
    its([:negative_reviews_count]){ is_expected.to eq 0 }
  end

  describe 'game with no developer' do
    cassette_subject(33730, '18_wheel')
    its([:developer]){ is_expected.to eq nil }
    its([:publisher]){ is_expected.to eq 'ValuSoft'}
  end

  describe 'game with no genre' do
    cassette_subject(55020, 'air_forte')
    its([:genre]){ is_expected.to eq nil }
  end

  describe 'game with a a different ID for the community hub (and thus reviews)' do
    cassette_subject(2028016, 'fallout_new_vegas_ue')
    its([:community_hub_id]){ is_expected.to eq 22380 }
  end

  describe 'released_at' do
    describe 'game with an old release date' do
      cassette_subject(6910, 'deus_ex_game_of_the_year')
      it{
        expect(Time.parse(subject[:released_at]))
        .to be_within(1.minute).of Time.parse('22 Jun, 2000')
      }
    end

    describe 'unreleased game' do
      cassette_subject(508460, 'max_control')
      its([:released_at]){ is_expected.to be_nil}
    end
  end

  describe 'vr_only game' do
    cassette_subject(342180, 'arizona_sunshine')
    its([:vr_only]){ is_expected.to eq true }
  end
end
