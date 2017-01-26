module Scrapers::Benchmarks
  describe Runner, cassette: true do
    it 'should scrap all the GPUs benchmarks' do
      runner = Scrapers::Benchmarks::Runner.new
      gpus = runner.run.output
      # Just basic checking
      expect(gpus.size).to be > 1000
      expect(gpus.find{ |gpu| gpu[:name] == 'GeForce GTX 980 Ti' }).to eq({
        name: 'GeForce GTX 980 Ti',
        value: 11507
      })
    end
  end
end
