describe Scrapers::Base::PageProcessor, cassette: true do
  it 'should yield the output of the page processing' do
    stub_url('www.purple.com', 200, '<html></html>')

    class Processor < Scrapers::Base::PageProcessor
      def process_page
        yield('Yeah!')
      end
    end

    loader = Scrapers::TrueLoader.new
    pl = Processor.new('www.purple.com', loader)

    pl_load_cb = lambda{}
    loader_run_cb = lambda{}

    expect(pl_load_cb).to receive(:call){ |output| expect(output).to eq('Yeah!') }
    expect(loader_run_cb).to receive(:call){ |response| expect(response.body).to eq('<html></html>') }

    pl.load(&pl_load_cb)
    loader.run(&loader_run_cb)
  end

  it 'should handle nested requests' do
    stub_url('www.purple.com', 200, '<html>Mmm</html>')
    stub_url('www.example.com', 200, '<html>Potato</html>')

    class ExampleProcessor < Scrapers::Base::PageProcessor
      def process_page
        yield('Bye')
      end
    end

    class PurpleProcessor < Scrapers::Base::PageProcessor
      def process_page
        add('www.example.com', ExampleProcessor) do |output|
          yield('Hello' + output)
        end
      end
    end

    loader = Scrapers::TrueLoader.new
    pl = PurpleProcessor.new('www.purple.com', loader)

    pl_load_cb = lambda{}
    loader_run_cb = lambda{}

    expect(pl_load_cb).to receive(:call){ |output| expect(output).to eq('HelloBye') }
    expect(loader_run_cb).to receive(:call).ordered{ |response| expect(response.body).to eq('<html>Mmm</html>') }
    expect(loader_run_cb).to receive(:call).ordered{ |response| expect(response.body).to eq('<html>Potato</html>') }

    pl.load(&pl_load_cb)
    loader.run(&loader_run_cb)
  end

  describe '#css!' do
    class Processor < Scrapers::Base::PageProcessor
      def process_page

      end
    end

    it 'should raise an InvalidPageError if no match found' do
      stub_url('www.example.com', 200, '<html></html>')
      expect{
        loader = Scrapers::TrueLoader.new
        pl = Processor.new('www.example.com', loader)
        pl.load{}
        loader.run{}
        pl.css!('#foo')
      }.to raise_error Scrapers::Errors::InvalidPageError
    end

    it 'should not raise an InvalidPageError if the match is found' do
      stub_url('www.example.com', 200, '<html><div id="foo"></div></html>')
      expect{
        loader = Scrapers::TrueLoader.new
        pl = Processor.new('www.example.com', loader)
        pl.load{}
        loader.run{}
        pl.css!('#foo')
      }.to_not raise_error
    end
  end
end
