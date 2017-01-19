

module Scrapers
  describe ScrapReport do
    describe '#start' do
      it 'should set the #started_at to Time.now' do
        s = ScrapReport.new 'steam_game'
        s.start
        expect(s.started_at).to be_within(1.second).of(Time.now)
      end
    end

    describe '#finish' do
      it 'should set the #finished_at to Time.now' do
        s = ScrapReport.new 'steam_game'
        s.finish
        expect(s.finished_at).to be_within(1.second).of(Time.now)
      end
    end

    describe '#elapsed_time' do
      it 'should return the elapsed seconds from #start to #finish' do
        s = ScrapReport.new 'steam_game'
        s.start
        Timecop.travel(Time.now + 10.seconds) do
          s.finish
          expect(s.elapsed_time).to eq 10.seconds
        end
      end
    end

    describe '#elapsed_time_human' do
      it 'should return the elapsed time in minutes and seconds' do
        s = ScrapReport.new 'steam_game'
        s.start
        Timecop.travel(Time.now + 80.seconds) do
          s.finish
          expect(s.elapsed_time_human).to eq '1m 20s'
        end
      end
    end

    describe '#error_reporter' do
      it 'should generate an #error_reporter with the stored exception' do
        s = ScrapReport.new 'steam_game'
        scraping_error = Scrapers::Errors::ScrapError.new('Oh no!')
        s.error! scraping_error
        expect(s.error?).to eq true
        expect(s.exception).to eq scraping_error
        error_reporter = s.error_reporter
        expect(error_reporter).to be_kind_of Scrapers::ErrorReporter
      end
    end
  end
end
