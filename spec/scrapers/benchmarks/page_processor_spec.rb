describe Scrapers::Benchmarks::PageProcessor, cassette: true do
  def processor_class; Scrapers::Benchmarks::PageProcessor end

  def benchmarks_url(type)
    "http://www.videocardbenchmark.net/#{type}.html"
  end

  def self.gpus_listing_cassette_subject(type)
    before_all_cassette do
      url = benchmarks_url(type)
      @result = scrap(url)
    end
    subject{ @result }
  end

  def self.subject_n(n)
    before(:all) do
      @gpu = @result[n]
    end
    subject{ @gpu }
  end

  describe 'URL detection' do
    it 'should detect the videocardbenchmark listing URL' do
      url = benchmarks_url('midlow_range_gpus')
      expect(url).to match processor_class.regexp
    end

    it 'should not match non-videocardbenchmark listing URLs' do
      url = "http://purple.com"
      expect(url).to_not match processor_class.regexp
    end
  end

  describe 'GPU listings' do
    gpus_listing_cassette_subject('midlow_range_gpus')

    its(:size){ is_expected.to eq 348 }

    describe '0' do
      subject_n(0)
      its([:name]) { is_expected.to eq 'Radeon HD 7520G + 7610M Dual' }
      its([:value]) { is_expected.to eq 464 }
    end

    describe '10' do
      subject_n(10)
      its([:name]) { is_expected.to eq 'GeForce 9600 GS' }
      its([:value]) { is_expected.to eq 451 }
    end

    describe '100' do
      subject_n(100)
      its([:name]) { is_expected.to eq 'GeForce 8600 GTS' }
      its([:value]) { is_expected.to eq 300 }
    end
  end

  describe 'GPU listing with 1000nds' do
    gpus_listing_cassette_subject('high_end_gpus')

    describe '0' do
      subject_n(0)
      its([:name]) { is_expected.to eq 'NVIDIA TITAN X' }
      its([:value]) { is_expected.to eq 13195 }
    end
  end
end
