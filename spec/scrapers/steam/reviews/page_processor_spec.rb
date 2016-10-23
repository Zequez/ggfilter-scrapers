describe Scrapers::Steam::Reviews::PageProcessor, cassette: true do
  def processor_class; Scrapers::Steam::Reviews::PageProcessor end

  def self.game_cassette_subject(app_id, name)
    before_all_cassette(name) do
      url = processor_class.generate_url(app_id)
      loader = Scrapers::Loader.new(processor_class, url)
      @result = loader.scrap
    end
    subject{ @result }
  end

  describe 'URL detection' do
    it 'should not detect and app alone' do
      url = 'http://steamcommunity.com/app/1234'
      expect(url).to_not match processor_class.regexp
    end

    it 'should detect a review page' do
      url = processor_class.generate_url(12345, page: 3)
      expect(url).to match processor_class.regexp
    end
  end

  describe 'loading a game with a single page of reviews' do
    game_cassette_subject 498680, 'shadows-of-truth'

    its([:positive]){ is_expected.to eq [0.1, 9.1, 0.5] }
    its([:negative]){ is_expected.to eq [0.8, 2.5, 0.3, 0.9] }
  end

  describe 'loading a game with multiple pages of reviews' do
    game_cassette_subject 331290, 'miko-gakkou'

    its([:positive]){ is_expected.to match_array [1.4, 1.5, 0.9, 0.3, 3, 12, 4, 6, 0.1] }
    its([:negative]){ is_expected.to match_array [0.7, 0.1, 1.2] }
  end
end
