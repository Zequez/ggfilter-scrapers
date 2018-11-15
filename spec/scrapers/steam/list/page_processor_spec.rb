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
        "!AnyWay!",
        "!LABrpgUP!",
        "#Archery",
        "#CuteSnake",
        "#CuteSnake 2",
        "#Have A Sticker",
        "#KILLALLZOMBIES",
        "#monstercakes",
        "#SelfieTennis",
        "#SkiJump",
        "#WarGames",
        "$1 Ride",
        ">//:System.Hack",
        ">Mars Taken",
        ">observer_",
        "\"BUTTS: The VR Experience\"",
        "\"Glow Ball\" - The billiard puzzle game",
        "\"Project Whateley\"",
        "\"TWO DRAW\"",
        "'1st Core: The Zombie Killing Cyborg'",
        "'n Verlore Verstand",
        "(VR)西汉帝陵 The Han Dynasty Imperial Mausoleums",
        "- Arcane Raise -"
      ] }
    end
  end

  describe ':price && :sale_price' do
    context 'page with items on sale' do
      specific_subject('1954 Alcatraz')
      its([:price]) { is_expected.to eq 999 }
      its([:sale_price]) { is_expected.to eq 99 }
    end

    context 'empty price but with release date' do
      specific_subject('The Occluder')
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
      attributes_subject('\'90s Football Stars Purple Tree', :name)
      it { is_expected.to eq [] }
    end

    context 'non-date release date' do
      specific_subject('SAVAGE: The Shard of Gosen')
      its([:steam_published_at]) { is_expected.to eq nil }
      its([:text_release_date]) { is_expected.to eq 'Coming Soon' }
    end

    context 'general date release date' do
      specific_subject('Russian Love Story')
      its([:steam_published_at]) { is_expected.to eq nil }
      its([:text_release_date]) { is_expected.to eq 'Nov 2018' }
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

      it {
        expect(subject.size).to be > 0
        subject.each do |s|
          expect(s[0]).to be_kind_of Fixnum
          expect(s[1]).to be_kind_of Fixnum
        end
      }
    end
  end

  describe ':thumbnail' do
    context 'a simple page' do
      attributes_subject('race the sun', :thumbnail)

      it{
        expect(subject.size).to be > 0
        subject.each do |s|
          expect(s).to match /^https:\/\/.*\.jpg/
        end
      }
    end
  end
end
