describe Scrapers::CustomLogger, cassette: true do
  it 'should allow weird ASCII-8BIT texts when writing to disk' do
    weird_page = Typhoeus.get 'http://store.steampowered.com/app/209160'
    scrap_request = Scrapers::ScrapRequest.new('http://store.steampowered.com/app/209160')
    scrap_request.set_response weird_page
    Scrapers.logger.store_error_page scrap_request
  end
end
