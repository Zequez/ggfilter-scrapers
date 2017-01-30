describe Scrapers::Errors do
  describe Scrapers::Errors::ScrapError do
    it 'should maintain the message and backtrace of the old error' do
      response = double('Response',
        body: 'hello',
        request: double('Request',
          url: 'http://example.com'
        )
      )

      begin
        raise 'potato'
      rescue StandardError => e
        scrap_error = Scrapers::Errors::ScrapError.new(
          e.message,
          e.backtrace,
          response
        )
      end

      expect(scrap_error.message).to eq e.message
      expect(scrap_error.backtrace).to eq e.backtrace
      expect(scrap_error.html).to eq response.body
      expect(scrap_error.url).to eq response.request.url
    end
  end
end
