module Scrapers
  describe Loader do
    class StubProcessor < Scrapers::Base::PageProcessor
      def process_page
        yield('one')
      end
    end

    class StubNestedProcessor < Scrapers::Base::PageProcessor
      def process_page
        yield('two')
      end
    end

    def stub_page(url, status, body)
      Typhoeus.stub(url).and_return(Typhoeus::Response.new(code: status, body: body))
    end

    describe '#new' do
      it 'should take a processor, a list of URLs and options' do
        expect{ Loader.new(Base::PageProcessor, ['http::/www.example.com'], {}) }.to_not raise_error
      end
    end

    describe 'loading error handling' do
      it 'should abort the scraping a page does not load correctly' do
        url = 'http://www.example.com'
        loader = Loader.new(StubProcessor, [url])
        stub_page(url, 401, '')
        expect{loader.scrap{}}.to raise_error do |error|
          expect(error).to be_a(Errors::ScrapError)
          expect(error).to be_a(Errors::LoadingError)
        end
      end

      it 'should try to load a page multiple times before giving up and throwing an error' do
        url = 'http://www.example.com'
        loader = Loader.new(StubProcessor, [url], {request_retry_count: 3})
        stub_page(url, 401, '')
        stub_page(url, 401, '')
        stub_page(url, 200, '')
        expect{loader.scrap{}}.to_not raise_error
      end

      it 'should treat redirections as errors' do
        url = 'http://www.example.com'
        loader = Loader.new(StubProcessor, [url])
        stub_page(url, 302, '')
        expect{loader.scrap{}}.to raise_error do |error|
          expect(error).to be_a(Errors::ScrapError)
          expect(error).to be_a(Errors::LoadingError)
        end
      end

      it 'should treat timeouts as errors' do
        # Not sure how to test this, but Typhoeus takes care of it, so no much to test really.
      end

      it 'should abort the scraping when a page does not contain the expected shape' do
        url = 'http:/www.example.com'

        class ErrorProcessor < Scrapers::Base::PageProcessor
          def process_page
            css!('#potato')
          end
        end

        loader = Loader.new(ErrorProcessor, [url])
        stub_page(url, 200, '<html></html>')
        expect{loader.scrap{}}.to raise_error do |error|
          expect(error).to be_a(Errors::ScrapError)
          expect(error).to be_a(Errors::InvalidPageError)
        end
      end
    end
  end
end
