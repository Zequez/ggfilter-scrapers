describe Scrapers::Steam::Reviews::PageProcessor, cassette: true do
  def processor_class; Scrapers::Steam::Reviews::PageProcessor end

  def steam_reviews_url(app_id, index = 0, language = 'default', filter = 'toprated')
    offset = index * 10
    page = index + 1
    "http://steamcommunity.com/app/#{app_id}/homecontent/?l=english&userreviewsoffset=#{offset}&p=#{page}&itemspage=2&screenshotspage=2&videospage=2&artpage=2&allguidepage=2&webguidepage=2&integratedguidepage=2&discussionspage=2&appHubSubSection=10&browsefilter=#{filter}&filterLanguage=#{language}&searchText="
  end

  def self.game_cassette_subject(app_id, name)
    before_all_cassette(name) do
      url = steam_reviews_url(app_id)
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
      url = steam_reviews_url(12345, 3)
      expect(url).to match processor_class.regexp
    end
  end

  describe 'loading a game with a single page of reviews' do
    game_cassette_subject 381010, 'orion'

    its([:positive]){ is_expected.to eq [1.7, 13.8, 0.9, 2.3] }
    its([:negative]){ is_expected.to eq [3.6] }
  end

  describe 'loading a game with multiple pages of reviews' do
    game_cassette_subject 319470, 'ninja_pizza_girl'

    its([:positive]){ is_expected.to match_array [2.4,4.2,2,3.7,2.9,2.2,4,1.1,1.3,2.6,0.5,0.5,10.6,0.4,1.2,2.4,2.2,2.5,2,0.8,0.1,1.5,2.4,5.9,6.7,1.2,4.2,1,0.8,2.6,1,2.7,2.4,9.7] }
    its([:negative]){ is_expected.to match_array [1.7] }
  end
end
