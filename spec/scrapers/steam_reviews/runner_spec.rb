describe Scrapers::SteamReviews::Runner, cassette: true do
  with_model_extended(
    :Game,
    [Scrapers::SteamList::GameExtension, Scrapers::SteamReviews::GameExtension],
    [Scrapers::SteamList::Migration::M1, Scrapers::SteamReviews::Migration::M1]
  )

  it 'should scrap all the games given' do
    ninja = Game.create steam_id: 319470, steam_reviews_count: 40 # Ninja Pizza Girl
    orion = Game.create steam_id: 381010, steam_reviews_count: 6 # Orion: A Sci-Fi Visual Novel

    runner = Scrapers::SteamReviews::Runner.new(games: [ninja, orion])
    runner.run

    expect(ninja.positive_steam_reviews).to eq [2.4, 3.0, 3.7, 2.9, 4.0, 4.2, 1.1, 2.2, 1.3, 2.6, 1.3, 2.3, 0.4, 2.4, 2.2, 3.4, 0.5, 2.0, 0.8, 0.6, 0.1, 1.5, 2.7, 4.2, 11.8, 5.9, 3.0, 1.2, 2.0, 0.8, 3.0, 2.7, 2.6, 9.7, 2.4, 0.7]
    expect(ninja.negative_steam_reviews).to eq [1.7, 1.4]
    expect(ninja.steam_reviews_scraped_at).to be_within(1.minute).of(Time.now)
    expect(orion.positive_steam_reviews).to eq [1.7, 13.8, 2.3, 0.9, 0.8]
    expect(orion.negative_steam_reviews).to eq [3.6]
    expect(orion.steam_reviews_scraped_at).to be_within(1.minute).of(Time.now)
  end
end
