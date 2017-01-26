describe Scrapers::Steam::List::PageProcessor, cassette: true, type: :steam_list do
  def self.attributes_subject(page_or_query, attribute_name)
    subject do
      response = Typhoeus.get steam_list_url(page_or_query)
      @result = Scrapers::Steam::List::PageProcessor.new(response.body).process_page
      @result.map do |h|
        JSON::Validator.validate! Scrapers::Steam::List::SCHEMA, h
        if attribute_name.kind_of? Array
          attribute_name.map{|n| h[n]}
        else
          h[attribute_name]
        end
      end
    end
  end

  def self.specific_subject(query)
    subject do
      response = Typhoeus.get steam_list_url(query)
      @result = Scrapers::Steam::List::PageProcessor.new(response.body).process_page
      JSON::Validator.validate! Scrapers::Steam::List::SCHEMA, @result[0]
      @result[0]
    end
  end

  describe 'error handling' do
    it 'should raise an error if the page is invalid' do
      expect{ Scrapers::Steam::List::PageProcessor.new('<html></html>').process_page }
        .to raise_error(/Could not find/i)
    end
  end

  describe 'games with neither price AND release date' do
    attributes_subject('canyon capers', :name)

    it{ is_expected.to eq ['Canyon Capers'] }
  end

  describe ':steam_id' do
    context 'regular page' do
      attributes_subject('potatoman', :steam_id)

      it{ is_expected.to eq [
        328500, 341120
      ] }
    end
  end

  # JSON.stringify([].slice.call(document.querySelectorAll('.title')).map((el)=>el.innerText), null, 2)
  describe ':name' do
    context 'regular page' do
      attributes_subject(1, :name)

      it{ is_expected.to eq [
        "! That Bastard Is Trying To Steal Our Gold !",
        "#KILLALLZOMBIES",
        "#SelfieTennis",
        "#SkiJump",
        "$1 Ride",
        "\"BUTTS: The VR Experience\"",
        "\"Glow Ball\" - The billiard puzzle game",
        "\"Heroes of Card War\"",
        "'n Verlore Verstand",
        ".EXE",
        "//N.P.P.D. RUSH//- The milk of Ultraviolet",
        "//SNOWFLAKE TATTOO//",
        "0 Day",
        "0RBITALIS",
        "1 Moment Of Time: Silentville",
        "1,000 Heads Among the Trees",
        "1... 2... 3... KICK IT! (Drop That Beat Like an Ugly Baby)",
        "10 Minute Barbarian",
        "10 Minute Tower",
        "10 Second Ninja",
        "10 Second Ninja X",
        "10 Years After",
        "10,000,000",
        "100% Orange Juice",
        "1000 Amps"
      ] }
    end
  end

  describe ':price && :sale_price' do
    context 'regular page without sales' do
      attributes_subject(1, :price)

      it {is_expected.to eq [
        299,
        1199,
        1999,
        nil,
        99,
        99,
        399,
        nil,
        1499,
        599,
        399,
        499,
        699,
        999,
        99,
        699,
        999,
        499,
        1499,
        999,
        999,
        599,
        499,
        699,
        499,
      ]}
    end

    context 'page with items on sale' do
      specific_subject('Doom & Destiny Advanced')
      its([:price]) { is_expected.to eq 999 }
      its([:sale_price]) { is_expected.to eq 799 }
    end

    context 'empty price but with release date' do
      specific_subject('Drift King: Survival')
      its([:price]) { is_expected.to eq nil }
      its([:sale_price]) { is_expected.to eq nil }
    end
  end

  describe ':steam_published_at' do
    context 'regular release date' do
      specific_subject('1954 Alcatraz')
      it{ expect(Time.parse(subject[:steam_published_at])).to be_within(1.hour).of Time.parse('Mar 11, 2014') }
    end

    context 'empty release date (and price)' do
      attributes_subject('Depression vive', :name)
      it { is_expected.to eq [] }
    end

    context 'non-date release date' do
      specific_subject('SAVAGE: The Shard of Gosen')
      its([:steam_published_at]) { is_expected.to eq nil }
      its([:text_release_date]) { is_expected.to eq 'Coming Soon' }
    end

    context 'general date release date' do
      specific_subject('Drift King: Survival')
      its([:steam_published_at]) { is_expected.to eq nil }
      its([:text_release_date]) { is_expected.to eq 'Nov 2016' }
    end
  end

  describe ':platforms' do
    context 'all 3 platforms' do
      specific_subject('race the sun')
      its([:platforms]) { are_expected.to match_array [:mac, :win, :linux] }
    end
  end

  describe ':reviews_count, :reviews_ratio' do
    context 'a simple page' do
      attributes_subject('race the sun', [:reviews_count, :reviews_ratio])

      it { is_expected.to eq [
        [4685, 93], [327, 22], [35, 65], [13, 69], [0, 50], [204, 68], [0, 50]
      ] }
    end
  end

  describe ':thumbnail' do
    context 'a simple page' do
      attributes_subject('race the sun', :thumbnail)

      it { is_expected.to eq [
        "http://cdn.akamai.steamstatic.com/steam/apps/253030/capsule_sm_120.jpg?t=1447358697",
        "http://cdn.akamai.steamstatic.com/steam/apps/246940/capsule_sm_120.jpg?t=1447358349",
        "http://cdn.akamai.steamstatic.com/steam/apps/336630/capsule_sm_120.jpg?t=1478620773",
        "http://cdn.akamai.steamstatic.com/steam/apps/444550/capsule_sm_120.jpg?t=1462350363",
        "http://cdn.akamai.steamstatic.com/steam/apps/427570/capsule_sm_120.jpg?t=1476961171",
        "http://cdn.akamai.steamstatic.com/steam/apps/253880/capsule_sm_120.jpg?t=1450522565",
        "http://cdn.akamai.steamstatic.com/steam/apps/467570/capsule_sm_120.jpg?t=1478615119"]
      }
    end
  end
end
