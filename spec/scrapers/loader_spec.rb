describe Scrapers::Loader do
  let(:s){ Scrapers }

  describe '#new' do
    it 'should accept an URL as the first argument and a list of processors as the second argument' do
      expect{ s::Loader.new(s::Base::PageProcessor, 'http::/potato.com') }.to_not raise_error
    end
  end

  describe 'loading error handling' do

  end

  describe '#scrap', cassette: true do
    describe 'errors handling' do
      describe 'non successful HTTP responses' do
        it 'should follow redirections' do
          response = nil
          processor = Class.new(s::Base::PageProcessor) do
            define_method :process_page do
              response = @scrap_request.response
            end
          end

          scraper = s::Loader.new(processor, 'http://goo.gl/F89MjN')
          scraper.scrap

          expect(response.code).to eq 200
          expect(response.request.url).to_not eq 'http://www.purple.com'
        end

        it 'should ignore timeouts' do
          # Not really sure how to test this
        end

        it 'should ignore anything that is not successful' do
          response = nil
          processor = Class.new(s::Base::PageProcessor) do
            define_method :process_page do
              response = @scrap_request.response
            end
          end

          scraper = s::Loader.new(processor, ['http://www.purple.com/404', 'http://nreisoanoeirnstioersnat.info'])
          scraper.scrap

          expect(response).to eq nil
        end
      end

      it 'should create an error file with an error if an error in the processor is raised' do
        processor = Class.new(s::Base::PageProcessor) do
          define_method(:process_page) do
            raise 'Potato'
          end
        end

        scraper = s::Loader.new(processor, 'http://www.purple.com', continue_with_errors: true)
        expect(scraper.scrap).to eq nil
        time = Time.now.strftime('%Y-%m-%d')
        expect(File.exists? "#{Scrapers.app_root}/log/error_pages/#{time}_http___www.purple.com.html").to eq true
        expect(File.exists? "#{Scrapers.app_root}/log/error_pages/#{time}_http___www.purple.com.backtrace").to eq true
      end

      it 'should yield a scrap_requests with errors' do
        processor = Class.new(s::Base::PageProcessor) do
          define_method :process_page do
            if @url == 'http://purple.com'
              add_to_queue 'http://www.purple.com/404'
              add_to_queue 'http://www.example.com'
              raise 'potato'
            end
            'yes'
          end
        end
        scraper = s::Loader.new(
          processor,
          ['http://purple.com'],
          continue_with_errors: true
        )

        yield_block = lambda{ |scrap_request| }
        expectations = lambda do |sr|
          case sr.url
          when 'http://purple.com' then expect(sr.error?).to eq true
          when 'http://www.purple.com/404' then expect(sr.error?).to eq true
          else
            expect(sr.error?).to eq false
          end

          if sr.root.all_finished?
            expect(sr.root.any_error?).to eq true
          end
        end
        expect(yield_block).to receive(:call, &expectations).exactly(3).times
        scraper.scrap(yield_with_errors: true, collect: true, &yield_block)
      end
    end

    it 'should raise a NoPageProcessorFoundError error if no processor was found for the page' do
      processor = Class.new(s::Base::PageProcessor) do
        regexp %r{rsarsarsa}
      end

      scraper = s::Loader.new(processor, 'http://www.purple.com')
      expect{scraper.scrap}.to raise_error s::NoPageProcessorFoundError
    end

    it 'should process each page and return the processed data' do
      processor = Class.new(s::Base::PageProcessor) do
        regexp %r{http://www\.purple\.com}

        define_method :process_page do
          'Yeaaaah!'
        end
      end

      scraper = s::Loader.new(processor, 'http://www.purple.com')
      expect(scraper.scrap).to eq 'Yeaaaah!'
    end

    it 'should get the full data by calling the inject method' do
      processor = Class.new(s::Base::PageProcessor) do
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
      class ExtendedProcessor < s::Base::PageProcessor
        regexp %r{http://www\.purple\.com}

        def process_page
          ['Yeaaaah!', 'Potato!']
        end
      end

      scraper = s::Loader.new(ExtendedProcessor, 'http://www.purple.com')
      expect(scraper.scrap).to eq ['Yeaaaah!', 'Potato!']
    end

    it 'should yield the a scrap_request with the data as each page loads to a block given in scrap' do
      class Processor < s::Base::PageProcessor
        def process_page
          @@count ||= 0
          @@count += 1
        end
      end

      scraper = s::Loader.new(
        Processor,
        ['http://www.zombo.com', 'http://www.purple.com', 'http://www.example.com']
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
      end
      expect(testYieldBlock).to receive(:call) do |scrap_request|
        expect(scrap_request.output).to eq 2
        expect(scrap_request.url).to eq 'http://www.purple.com'
        expect(scrap_request.root_url).to eq 'http://www.purple.com'
      end
      expect(testYieldBlock).to receive(:call) do |scrap_request|
        expect(scrap_request.output).to eq 3
        expect(scrap_request.url).to eq 'http://www.example.com'
        expect(scrap_request.root_url).to eq 'http://www.example.com'
      end
      scraper.scrap(&yieldBlock)
    end

    it 'should pass wether the processor is procesing an initial URL or an additional' do
      mock_processor = Class.new(s::Base::PageProcessor) do

      end

      processor = Class.new(s::Base::PageProcessor) do
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
