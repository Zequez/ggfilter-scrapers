describe Scrapers::Benchmarks::Runner, cassette: true do
  with_model_extended(
    :Gpu,
    [],
    [Scrapers::Benchmarks::Migration::M1]
  )

  it 'should scrap all the GPUs benchmarks' do
    runner = Scrapers::Benchmarks::Runner.new
    runner.run
    # Just basic checking
    expect(Gpu.count).to be > 1000
    expect(Gpu.where(name: 'GeForce GTX 980 Ti').first.value).to eq 11543
  end

  it 'should update existing benchmarks on subsequent scraps' do
    gpu = Gpu.create name: 'GeForce GTX 980 Ti', value: 11542

    runner = Scrapers::Benchmarks::Runner.new
    runner.run
    gpu.reload
    expect(gpu.value).to eq 11543
  end
end
