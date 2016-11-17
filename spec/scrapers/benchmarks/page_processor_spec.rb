describe Scrapers::Benchmarks::PageProcessor, cassette: true do
  def processor_class; Scrapers::Benchmarks::PageProcessor end

  def benchmarks_url(type)
    "http://www.videocardbenchmark.net/#{type}.html"
  end

  def self.gpus_listing_cassette_subject(type)
    before_all_cassette do
      url = benchmarks_url(type)
      @result = vcr_processor_request(processor_class, url)
    end
    subject{ @result }
  end

  def self.subject_n(n)
    before(:all) do
      @gpu = @result[n]
    end
    subject{ @gpu }
  end

  describe 'GPU listings' do
    gpus_listing_cassette_subject('midlow_range_gpus')

    its(:size){ is_expected.to eq 337 }

    describe '0' do
      subject_n(0)
      its([:name]) { is_expected.to eq 'Radeon R5 M230' }
      its([:value]) { is_expected.to eq 459 }
    end

    describe '10' do
      subject_n(10)
      its([:name]) { is_expected.to eq 'Quadro 410' }
      its([:value]) { is_expected.to eq 433 }
    end

    describe '100' do
      subject_n(100)
      its([:name]) { is_expected.to eq 'Radeon HD 6450' }
      its([:value]) { is_expected.to eq 285 }
    end
  end

  describe 'GPU listing with 1000nds' do
    gpus_listing_cassette_subject('high_end_gpus')

    describe '0' do
      subject_n(0)
      its([:name]) { is_expected.to eq 'NVIDIA TITAN X' }
      its([:value]) { is_expected.to eq 13195 }
    end

    it 'should ignore all the SLI/Crossfire benchmarks (signaled with a plus sign)' do
      names = @result.map{|gpu| gpu[:name]}
      expect(names).to_not include('Radeon R9 Fury + Fury X')
      expect(names).to_not include('Radeon R7 + HD 7700 Dual')
      expect(names).to_not include('Radeon HD 8670D + 6670 Dual')
      expect(names).to_not include('Radeon HD 7560D + HD 7700 Dual')
    end
  end
end
