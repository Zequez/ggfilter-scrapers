describe Scrapers::BasicRunner do
  describe 'partial yielding' do
    it 'should allow for partial yielding' do
      class MyRunner < Scrapers::BasicRunner
        def run!
          partial_output_yield('potato')
          partial_output_yield('motato')
        end
      end

      block = lambda{}
      expect(block).to receive(:call).with('potato')
      expect(block).to receive(:call).with('motato')
      MyRunner.new.run(&block)
    end
  end

  describe 'errors handling and reporting' do
    before(:all) { Scrapers::BasicRunner.instant_raise = false }
    after(:all) { Scrapers::BasicRunner.instant_raise = true }

    it 'catch an error when running and add it to the report' do
      class MyRunner < Scrapers::BasicRunner
        def run!
          report.add_warning 'ohhh'
          raise 'hey oh'
        end
      end

      report = MyRunner.new.run
      expect(report.warnings[0]).to match(/ohhh/)
      expect(report.errors[0].message).to match(/hey oh/)
    end

    it 'should catch up to 10 errors when parsing successful requests' do
      my_runner_class = Class.new(Scrapers::BasicRunner) do
        def run!
          report.output = 'ohh'
          10.times do |i|
            queue("http://example.com/#{i}") do
              raise "Error#{i}"
            end
          end
          loader.run
        end
      end

      10.times do |i|
        Typhoeus.stub("http://example.com/#{i}")
          .and_return(Typhoeus::Response.new(code: 200, body: ''))
      end

      report = my_runner_class.new.run

      expect(report.output).to eq 'ohh'
      expect(report.aborted).to eq false
      expect(report.errors.size).to eq 10
      10.times do |i|
        expect(report.errors[i].message).to match(/error#{i}/i)
      end
    end

    it 'should abort on the eleventh error and set the output to nil, and aborted to true' do
      my_runner_class = Class.new(Scrapers::BasicRunner) do
        def run!
          report.output = 'ohh'
          11.times do |i|
            queue("http://example.com/#{i}") do
              raise "Error#{i}"
            end
          end
          loader.run
        end
      end

      11.times do |i|
        Typhoeus.stub("http://example.com/#{i}")
          .and_return(Typhoeus::Response.new(code: 200, body: ''))
      end

      report = my_runner_class.new.run

      expect(report.output).to eq nil
      expect(report.aborted).to eq true
      expect(report.errors.size).to eq 12
      11.times do |i|
        expect(report.errors[i].message).to match(/error#{i}/i)
      end
      expect(report.errors[11].message).to match(/too many/i)
    end
  end
end
