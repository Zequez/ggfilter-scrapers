describe Scrapers::Loader do
  let(:s){ Scrapers }

  describe '#new' do
    it 'should accept an URL as the first argument and a list of processors as the second argument' do
      expect{ s::Loader.new(s::BasePageProcessor, 'http::/potato.com') }.to_not raise_error
    end
  end

  describe '#scrap', cassette: true do
    it 'should raise a NoPageProcessorFoundError error if no processor was found for the page' do
      scraper = s::Loader.new(s::BasePageProcessor, 'http://www.purple.com')
      expect{scraper.scrap}.to raise_error s::NoPageProcessorFoundError
    end

    it 'should process each page and return the processed data' do
      processor = Class.new(s::BasePageProcessor) do
        regexp %r{http://www\.purple\.com}

        define_method :process_page do
          'Yeaaaah!'
        end
      end

      scraper = s::Loader.new(processor, 'http://www.purple.com')
      expect(scraper.scrap).to eq 'Yeaaaah!'
    end

    it 'should get the full data by calling the inject method' do
      processor = Class.new(s::BasePageProcessor) do
        regexp %r{http://www\.purple\.com}

        define_singleton_method :inject do |all_data, data|
          data + 'potato'
        end

        define_method :process_page do
          'Yeaaaah!'
        end
      end

      scraper = s::Loader.new(processor, 'http://www.purple.com')
      expect(scraper.scrap).to eq 'Yeaaaah!potato'
    end

    it "should process each page and return the processed data even if it's an array" do
      class ExtendedProcessor < s::BasePageProcessor
        regexp %r{http://www\.purple\.com}

        def process_page
          ['Yeaaaah!', 'Potato!']
        end
      end

      scraper = s::Loader.new(ExtendedProcessor, 'http://www.purple.com')
      expect(scraper.scrap).to eq ['Yeaaaah!', 'Potato!']
    end

    it 'should raise an exception when creating a Loader with different sizes URLs, inputs and resources' do
      expect{ s::Loader.new(s::BasePageProcessor, ['http://www.purple.com'], [1,2,3], [1]) }.to raise_error(ArgumentError)
    end

    it 'should yield the a scrap_request with the data as each page loads to a block given in scrap' do
      class Processor < s::BasePageProcessor
        regexp %r{.}

        def process_page
          @@count ||= 0
          @@count += 1
        end
      end

      scraper = s::Loader.new(
        Processor,
        ['http://www.zombo.com', 'http://www.purple.com', 'http://www.purple.com/potato'],
        [1234, 4321, 1111],
        [[1,2,3], [3,2,1], [1,1,1]]
      )

      # Couldn't find a way to test calls that worked with currying
      testYieldBlock = lambda{ |scrap_request| }
      yieldBlock = lambda do |scrap_request|
        testYieldBlock.call(scrap_request)
      end

      expect(testYieldBlock).to receive(:call) do |scrap_request|
        expect(scrap_request.output).to eq 1
        expect(scrap_request.url).to eq 'http://www.zombo.com'
        expect(scrap_request.root_url).to eq 'http://www.zombo.com'
        expect(scrap_request.resource).to eq [1,2,3]
        expect(scrap_request.input).to eq 1234
      end
      expect(testYieldBlock).to receive(:call) do |scrap_request|
        expect(scrap_request.output).to eq 2
        expect(scrap_request.url).to eq 'http://www.purple.com'
        expect(scrap_request.root_url).to eq 'http://www.purple.com'
        expect(scrap_request.resource).to eq [3,2,1]
        expect(scrap_request.input).to eq 4321
      end
      expect(testYieldBlock).to receive(:call) do |scrap_request|
        expect(scrap_request.output).to eq 3
        expect(scrap_request.url).to eq 'http://www.purple.com/potato'
        expect(scrap_request.root_url).to eq 'http://www.purple.com/potato'
        expect(scrap_request.resource).to eq [1,1,1]
        expect(scrap_request.input).to eq 1111
      end
      scraper.scrap(&yieldBlock)
    end

    it 'accept an input and a resource with the URL and pass it to the processor' do
      scrap_request = nil
      processor = Class.new(s::BasePageProcessor) do
        regexp %r{.}

        define_method(:initialize) do |sr|
          scrap_request = sr
        end

        define_method(:process_page){ 'ho ho ho' }
      end

      scraper = s::Loader.new(
        processor,
        'http://www.zombo.com',
        { some_data: 'hey' },
        { resource: 'yes' }
      )
      scraper.scrap

      expect(scrap_request.url).to eq 'http://www.zombo.com'
      expect(scrap_request.input).to eq(some_data: 'hey')
      expect(scrap_request.resource).to eq(resource: 'yes')
      expect(scrap_request.output).to eq 'ho ho ho'
    end

    it 'should pass wether the processor is procesing an initial URL or an additional' do
      mock_processor = Class.new(s::BasePageProcessor) do
        regexp %r{.}
      end

      processor = Class.new(s::BasePageProcessor) do
        regexp %r{.}

        define_method(:process_page) do
          add_to_queue 'http://www.purple.com'
        end
      end

      # processor

      expect(mock_processor).to receive(:new) do |scrap_request, &block|
        expect(scrap_request.root?).to eq true
        processor.new(scrap_request, &block)
      end

      expect(mock_processor).to receive(:new) do |scrap_request, &block|
        expect(scrap_request.root?).to eq false
        processor.new(scrap_request, &block)
      end

      scraper = s::Loader.new(
        mock_processor,
        'http://www.zombo.com'
      )
      scraper.scrap
    end
  end
end
