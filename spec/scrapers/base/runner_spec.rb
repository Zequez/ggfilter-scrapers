describe Scrapers::Base::Runner do
  describe 'error catching' do
    it 'should return a scrapig repport with #error? and #exception set to true' do
       stub_url('http://www.example.com', 403, '')

       class MockRunner < Scrapers::Base::Runner
         def name; 'mock_runner' end
         def processor; Scrapers::Base::PageProcessor end
         def urls; ['http://www.example.com'] end

         def report_msg
           '...'
         end
       end

       runner = MockRunner.new
       report = runner.run

       expect(report.error?).to eq true
       expect(report.exception).to be_kind_of Scrapers::Errors::LoadingError
       expect(report.exception).to be_kind_of Scrapers::Errors::ScrapError
       expect(report.finished_at).to_not be_nil
       expect(report.scraper_report).to eq nil
    end
  end

  describe 'return value' do
    after do
      Timecop.return
    end

    it 'should return a ScrapReport after running with the correct data' do
      stub_url('http://www.example.com', 200, '')

      class MockProcessor < Scrapers::Base::PageProcessor
        def process_page
          Timecop.travel(5.seconds.from_now)
        end
      end

      class MockRunner < Scrapers::Base::Runner
        def name; 'mock_runner' end
        def processor; MockProcessor end
        def urls; ['http://www.example.com'] end

        def report_msg
          '10 new games found or something'
        end
      end

      runner = MockRunner.new
      report = runner.run
      expect(report).to be_kind_of Scrapers::ScrapReport
      expect(report.scraper_name).to eq 'mock_runner'
      expect(report.scraper_report).to eq '10 new games found or something'
      expect(report.elapsed_time).to eq 5.seconds
      expect(report.error?).to eq false
    end
  end
end
