describe Scrapers::Base::PageProcessor, cassette: true do
  def new_scrap_request
    response = Typhoeus.get('http://www.purple.com')
    scrap_request = Scrapers::ScrapRequest.new('http://purple.com', 'http://purple.com')
    scrap_request.set_response response
    scrap_request
  end

  it 'should initialize with an ScrapRequest and a code block' do
    expect{
      Scrapers::Base::PageProcessor.new(new_scrap_request) do |url|

      end
    }.to_not raise_error
  end

  describe '.regexp' do
    it 'should return matching regex by default' do
      expect(Scrapers::Base::PageProcessor.regexp).to eq(/./)
    end

    it 'should save the regex when called with a value' do
      class ExtendedProcessor < Scrapers::Base::PageProcessor
        regexp %r{potato}
      end
      expect(ExtendedProcessor.regexp).to eq(/potato/)
      expect(Scrapers::Base::PageProcessor.regexp).to eq(/./)
    end
  end

  it 'should call the block given when calling #add_to_queue' do
    class ExtendedProcessor < Scrapers::Base::PageProcessor
      def process_page
        add_to_queue('rsarsa')
      end
    end

    block = lambda{ |url| }
    expect(block).to receive(:call).with('rsarsa')

    processor = ExtendedProcessor.new(new_scrap_request, &block)
    processor.process_page
  end
end
