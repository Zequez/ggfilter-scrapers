describe Scrapers::SteamGame::Runner, cassette: true do
  with_model_extended(
    :Game,
    [Scrapers::SteamList::GameExtension, Scrapers::SteamGame::GameExtension],
    [Scrapers::SteamList::Migration::M1, Scrapers::SteamGame::Migration::M1]
  )

  it 'should scrap all the games given' do
    bioshock_infinite = Game.create steam_id: 8870
    dota_2 = Game.create steam_id: 570
    runner = Scrapers::SteamGame::Runner.new(games: [bioshock_infinite, dota_2])
    runner.run
    # Just basic checking
    expect(bioshock_infinite.metacritic).to eq 94
    expect(bioshock_infinite.steam_game_scraped_at).to be_within(1.minute).of(Time.now)
    expect(dota_2.metacritic).to eq 90
    expect(dota_2.steam_game_scraped_at).to be_within(1.minute).of(Time.now)
  end
end
