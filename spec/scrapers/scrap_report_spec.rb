

module Scrapers
  describe ScrapReport do
    describe '#start' do
      it 'should set the #started_at to Time.now' do
        s = ScrapReport.new
        s.start
        expect(s.started_at).to be_within(1.second).of(Time.now)
      end
    end

    describe '#finish' do
      it 'should set the #finished_at to Time.now' do
        s = ScrapReport.new
        s.finish
        expect(s.finished_at).to be_within(1.second).of(Time.now)
      end
    end

    describe '#elapsed_time' do
      it 'should return the elapsed seconds from #start to #finish' do
        s = ScrapReport.new
        s.start
        Timecop.travel(Time.now + 10.seconds) do
          s.finish
          expect(s.elapsed_time).to eq 10.seconds
        end
      end
    end

    describe '#elapsed_time_human' do
      it 'should return the elapsed time in minutes and seconds' do
        s = ScrapReport.new
        s.start
        Timecop.travel(Time.now + 80.seconds) do
          s.finish
          expect(s.elapsed_time_human).to eq '1m 20s'
        end
      end
    end
  end
end
