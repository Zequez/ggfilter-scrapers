describe Scrapers::Base::Runner do
  it 'should catch any scraping abort from the Loader and create an error reporter' do
    stub_url('http://www.example.com', 403, '')

    class MockRunner < Scrapers::Base::Runner
      def name
        'mock_runner'
      end

      def processor
        Scrapers::Base::PageProcessor
      end

      def urls
        ['http://www.example.com']
      end
    end

    runner = MockRunner.new

    reporter_double = double
    expect(Scrapers::ErrorReporter).to receive(:new)
      .with(kind_of(Scrapers::Errors::ScrapAbortError), 'mock_runner')
      .and_return(reporter_double)
    expect(reporter_double).to receive(:commit)

    runner.run
  end
end
