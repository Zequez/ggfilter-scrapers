describe Scrapers::Steam::Reviews::PageProcessor, cassette: true do
  def processor_class; Scrapers::Steam::Reviews::PageProcessor end

  def self.game_cassette_subject(steam_id, name)
    before_all_cassette(name) do
      url = Scrapers::Steam::Reviews::Runner.generate_url(steam_id, 1)
      @result = Scrapers::Steam::Reviews::PageProcessor.new(Typhoeus.get(url).body).process_page
    end
    subject{ @result }
  end

  it 'should return nil if the page is empty' do
    expect(Scrapers::Steam::Reviews::PageProcessor.new('').process_page).to eq nil
  end

  describe 'loading a game reviews page' do
    game_cassette_subject 498680, 'shadows-of-truth'

    its([:positive]){ is_expected.to eq [9.6, 0.5, 0.3] }
    its([:negative]){ is_expected.to eq [0.8, 3.0, 3.5] }
  end
end
