require "json-schema"

describe Scrapers::Oculus::Runner, cassette: true do
  describe 'error handling' do
    before(:each) { Scrapers::Oculus::Runner.instant_raise = false }
    after(:each) { Scrapers::Oculus::Runner.instant_raise = true }

    it 'should return a report with an error with an invalid token' do
      report = Scrapers::Oculus::Runner.new(access_token: 'ARSARSARS').run
      expect(report.output).to eq nil
      expect(report.errors?).to eq true
      expect(report.errors[0].message).to match(/oauth/i)
    end
  end

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
    its([:price_regular]){ is_expected.to eq nil }
    it{ expect(Time.parse(subject[:released_at])).to(
      be_within(24.hour).of(Time.parse('2016-12-05'))
    )}
    its([:summary]){ expect(subject[:summary]).to match /SUPERHOT is the first person shooter/ }
    its([:version]){ is_expected.to eq '1.0.6' }
    its([:category]){ is_expected.to eq 'Games' }
    its([:genres]){ is_expected.to eq [
      'Action',
      'Fighting',
      'Shooter',
      'Simulation'
    ]}
    its([:languages]){ is_expected.to match_array [
      'English'
    ]}
    its([:developer]){ is_expected.to eq 'SUPERHOT' }
    its([:publisher]){ is_expected.to eq 'SUPERHOT Team' }

    its([:vr_mode]){ is_expected.to match_array ['STANDING'] }
    its([:vr_tracking]){ is_expected.to match_array ['FRONT_FACING'] }
    its([:vr_controllers]){ is_expected.to match_array ['OCULUS_TOUCH'] }

    its([:players]){ is_expected.to match_array ['SINGLE_USER'] }
    its([:comfort]){ is_expected.to eq 'COMFORTABLE_FOR_MOST' }
    its([:internet]){ is_expected.to eq 'NOT_REQUIRED' }

    its([:sysreq_hdd]){ is_expected.to be >= 3130973157 }
    its([:sysreq_cpu]){ is_expected.to eq 'i5 4590' }
    its([:sysreq_gpu]){ is_expected.to eq 'GTX 970 / Radeon RX 480' }
    its([:sysreq_ram]){ is_expected.to eq 8 }

    its([:rating_1]){ is_expected.to be >= 13 }
    its([:rating_2]){ is_expected.to be >= 12 }
    its([:rating_3]){ is_expected.to be >= 24 }
    its([:rating_4]){ is_expected.to be >= 71 }
    its([:rating_5]){ is_expected.to be >= 521 }
  end

  describe 'Dragon Front' do
    single_game 999515523455801 # dragon_front

    its([:name]){ is_expected.to eq 'Dragon Front' }
    its([:price]){ is_expected.to eq 0 }
    its([:price_regular]){ is_expected.to eq nil }
    its([:summary]){ expect(subject[:summary].gsub(/\s/, '')).to eq(
      <<-EOS.gsub(/\s/, '')
      Go back in time to rewrite the outcome of the second Great War by achieving total victory over other players in the very first turn-based, collectible miniature-battler in VR!
      EOS
    )}
    its([:version]){ is_expected.to eq '2.3.2.0' }
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
    its([:developer]){ is_expected.to eq 'High Voltage Software, Inc.' }
    its([:publisher]){ is_expected.to eq 'High Voltage Software, Inc.' }

    its([:vr_mode]){ is_expected.to match_array ['SITTING', 'STANDING'] }
    its([:vr_tracking]){ is_expected.to match_array ['FRONT_FACING'] }
    its([:vr_controllers]){ is_expected.to match_array ['GAMEPAD', 'OCULUS_REMOTE', 'OCULUS_TOUCH'] }

    its([:players]){ is_expected.to match_array ['SINGLE_USER', 'MULTI_USER'] }
    its([:comfort]){ is_expected.to eq 'COMFORTABLE_FOR_MOST' }
    its([:internet]){ is_expected.to eq 'REQUIRED' }

    its([:sysreq_hdd]){ is_expected.to be_within(1_000_000_000).of(9_393_613_525) }
    its([:sysreq_cpu]){ is_expected.to eq 'Intel i5-4590 equivalent or greater' }
    its([:sysreq_gpu]){ is_expected.to eq 'NVIDIA GTX 970 / AMD 290 equivalent or greater' }
    its([:sysreq_ram]){ is_expected.to eq 8 }

    its([:website_url]){ is_expected.to eq 'http://www.dragonfront.com/' }
  end

  describe 'game on sale' do
    single_game 1365103133543739 # space_jones_vr

    its([:name]){ is_expected.to eq 'Transpose' }
    its([:price]){ is_expected.to eq 1799 }
    its([:price_regular]){ is_expected.to eq 1999 }
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
    its([:comfort]){ is_expected.to eq 'COMFORTABLE_FOR_SOME' }
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

  describe 'scrap an entire section (new and updated games section, 12 items)' do
    it 'should validate with JSON Schema' do
      games = Scrapers::Oculus::Runner.new(section_id: 503326266763229).run.output
      expect(games.size).to eq 12
      games.each do |game|
        JSON::Validator.validate!(Scrapers::Oculus::SCHEMA, game)
      end
    end
  end

  # describe 'scrap top 100 games (a whole new level of testing)' do
  #   it 'should validate with JSON Schema' do
  #     games = Scrapers::Oculus::Runner.new(section_id: 358050124528384).run.output

  #     expect(games.size).to eq 100
  #     games.each do |game|
  #       JSON::Validator.validate!(Scrapers::Oculus::SCHEMA, game)
  #     end
  #   end
  # end
end
