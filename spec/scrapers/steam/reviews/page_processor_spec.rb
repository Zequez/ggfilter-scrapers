describe Scrapers::Steam::Reviews::PageProcessor, cassette: true do
  def processor_class; Scrapers::Steam::Reviews::PageProcessor end

  def self.game_cassette_subject(app_id, name)
    before_all_cassette(name) do
      url = processor_class.generate_url(app_id)
      @result = vcr_processor_request(processor_class, url)
    end
    subject{ @result }
  end

  describe 'error handling' do
    it 'should raise an InvalidPageError if the page is invalid' do
      expect { page_processor_for_html(processor_class, '<html></html>').process_page }
      .to raise_error(Scrapers::InvalidPageError)
    end
  end

  describe 'loading a game with a single page of reviews' do
    game_cassette_subject 498680, 'shadows-of-truth'

    its([:positive]){ is_expected.to eq [9.6, 0.5, 0.3] }
    its([:negative]){ is_expected.to eq [0.8, 3.0, 3.5] }
  end

  describe 'loading a game with multiple pages of reviews' do
    game_cassette_subject 331290, 'miko-gakkou'

    its([:positive]){ is_expected.to match_array [1.4, 1.5, 0.9, 0.3, 3, 12, 4, 6, 0.1] }
    its([:negative]){ is_expected.to match_array [0.7, 0.1, 1.2] }
  end
end
