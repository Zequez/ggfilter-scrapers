require "json-schema"

describe Scrapers::Oculus::Runner, cassette: true do
  def self.single_game(id)
    subject do
      output = Scrapers::Oculus::Runner.new(game_id: id).run.output
      JSON::Validator.validate!(Scrapers::Oculus::SCHEMA, output)
      output
    end
  end

  describe 'SUPERHOT VR' do
    single_game 1012593518800648 # SUPER         HOT

    its([:oculus_id]){ is_expected.to eq  1012593518800648 }
    its([:name]){ is_expected.to eq 'SUPERHOT VR' }
    its([:price]){ is_expected.to eq 2499 }
    its([:price_was]){ is_expected.to eq nil }
    its([:released_at]){ is_expected.to be_within(24.hour).of(Time.parse('2016-12-05')) }
    its([:summary]){ expect(subject[:summary].gsub(/\s/, '')).to eq(
      <<-EOS.gsub(/\s/, '')
        SUPERHOT is the first person shooter where time moves only when you move. No regenerating health bars. No conveniently placed ammo drops. It's just you, outnumbered and outgunned, grabbing the weapons of fallen enemies to shoot, slice, and maneuver through a hurricane of slow-motion bullets.
      EOS
    )}
    its([:version]){ is_expected.to eq '1.0_RC4' }
    its([:category]){ is_expected.to eq 'Games' }
    its([:genres]){ is_expected.to eq [
      'Action',
      'Fighting',
      'Puzzle',
      'Shooter',
      'Simulation'
    ]}
    its([:languages]){ is_expected.to match_array [
      'English'
    ]}
    its([:age_rating]){ is_expected.to eq 'Ages 17+' }
    its([:developer]){ is_expected.to eq 'SUPERHOT' }
    its([:publisher]){ is_expected.to eq 'SUPERHOT Team' }

    its([:vr_mode]){ is_expected.to match_array ['STANDING'] }
    its([:vr_tracking]){ is_expected.to match_array ['FRONT_FACING'] }
    its([:vr_controllers]){ is_expected.to match_array ['OCULUS_TOUCH'] }

    its([:players]){ is_expected.to match_array ['SINGLE_USER'] }
    its([:comfort]){ is_expected.to eq 'COMFORTABLE_FOR_MOST' }
    its([:internet]){ is_expected.to eq 'NOT_REQUIRED' }

    its([:sysreq_hdd]){ is_expected.to eq 3130973157 }
    its([:sysreq_cpu]){ is_expected.to eq 'i5 4590' }
    its([:sysreq_gpu]){ is_expected.to eq 'GTX 970 / Radeon RX 480' }
    its([:sysreq_ram]){ is_expected.to eq 8 }
  end

  describe 'Dragon Front' do
    single_game 999515523455801 # dragon_front

    its([:name]){ is_expected.to eq 'Dragon Front' }
    its([:price]){ is_expected.to eq 0 }
    its([:price_was]){ is_expected.to eq nil }
    its([:summary]){ expect(subject[:summary].gsub(/\s/, '')).to eq(
      <<-EOS.gsub(/\s/, '')
      Go back in time to rewrite the outcome of the second Great War by achieving total victory over other players in the very first turn-based, collectible miniature-battler in VR!
      EOS
    )}
    its([:version]){ is_expected.to eq '1.2.0.4' }
    its([:category]){ is_expected.to eq 'Games' }
    its([:genres]){ is_expected.to eq [
      'Action',
      'Casual',
      'Strategy',
      'Social'
    ]}
    its([:languages]){ is_expected.to match_array [
      'English',
      'French (France)',
      'German',
      'Chinese (China)',
      'Korean',
      'Spanish (Mexico)'
    ]}
    its([:age_rating]){ is_expected.to eq 'Ages 13+' }
    its([:developer]){ is_expected.to eq 'High Voltage Software, Inc.' }
    its([:publisher]){ is_expected.to eq 'High Voltage Software, Inc.' }

    its([:vr_mode]){ is_expected.to match_array [] }
    its([:vr_tracking]){ is_expected.to match_array [] }
    its([:vr_controllers]){ is_expected.to match_array ['GAMEPAD', 'OCULUS_REMOTE'] }

    its([:players]){ is_expected.to match_array ['SINGLE_USER', 'MULTI_USER'] }
    its([:comfort]){ is_expected.to eq 'COMFORTABLE_FOR_MOST' }
    its([:internet]){ is_expected.to eq 'REQUIRED' }

    its([:sysreq_hdd]){ is_expected.to eq 10851711759 }
    its([:sysreq_cpu]){ is_expected.to eq 'Intel i5-4590 equivalent or greater' }
    its([:sysreq_gpu]){ is_expected.to eq 'NVIDIA GTX 970 / AMD 290 equivalent or greater' }
    its([:sysreq_ram]){ is_expected.to eq 8 }

    its([:website_url]){ is_expected.to eq 'http://www.dragonfront.com/' }
  end

  describe 'game on sale' do
    single_game 823702124398242 # space_jones_vr

    its([:name]){ is_expected.to eq 'Space Jones VR' }
    its([:price]){ is_expected.to eq 999 }
    its([:price_was]){ is_expected.to eq 1599 }
  end

  describe 'intense comfort && 360 tracking' do
    single_game 1171112789643848 # 'dwvr'

    its([:name]){ is_expected.to eq 'DWVR' }
    its([:comfort]){ is_expected.to eq 'COMFORTABLE_FOR_FEW' }
    its([:vr_mode]){ is_expected.to match_array ['SITTING', 'ROOM_SCALE', 'STANDING'] }
    its([:vr_tracking]){ is_expected.to match_array ['FRONT_FACING', 'DEGREE_360'] }
  end

  describe 'vage game information' do
    single_game 1176906779016594 # 'vrog'

    its([:name]){ is_expected.to eq 'VRog' }
    its([:comfort]){ is_expected.to eq 'NOT_RATED' }
    its([:vr_controllers]){ is_expected.to match_array [] }
  end

  describe 'co-op && keyboard and mouse' do
    single_game 1114063828645217 # 'daydream_blue'

    its([:name]){ is_expected.to eq 'Daydream Blue' }
    its([:players]){ is_expected.to match_array [
      'SINGLE_USER',
      'MULTI_USER',
      'CO_OP'
    ]}
    its([:vr_controllers]){ is_expected.to match_array ['GAMEPAD', 'KEYBOARD_MOUSE'] }
  end

  describe 'weird internet' do
    single_game 1336762299669605 # 'medium'

    its([:internet]){ is_expected.to eq 'REQUIRED_FOR_DOWNLOAD' }
  end

  describe 'moderate comfort' do
    single_game 1039652702743731 # 'world_of_diving'

    its([:comfort]){ is_expected.to eq 'COMFORTABLE_FOR_SOME' }
  end

  describe 'scrap an entire section (featured games section, 8 items)' do
    it 'should validate with JSON Schema' do
      games = Scrapers::Oculus::Runner.new(section_id: 475911402609128).run.output

      expect(games.size).to eq 8
      expect(games.map{|s| s[:oculus_id]}).to eq [
        1174445049267874,
        999515523455801,
        1303301169681067,
        1207497572657758,
        1070597869619581,
        1115950031749190,
        1253785157981619,
        907700232632286
      ]

      games.each do |game|
        JSON::Validator.validate!(Scrapers::Oculus::SCHEMA, game)
      end
    end
  end

  describe 'scrap top 100 games (a whole new level of testing)' do
    it 'should validate with JSON Schema' do
      games = Scrapers::Oculus::Runner.new(section_id: 358050124528384).run.output

      expect(games.size).to eq 100
      games.each do |game|
        JSON::Validator.validate!(Scrapers::Oculus::SCHEMA, game)
      end
    end
  end
end
