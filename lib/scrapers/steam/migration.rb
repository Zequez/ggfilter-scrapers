module Scrapers::Steam
  class Migration < ActiveRecord::Migration[4.2]
    def change
      create_table :steam_games do |t|
        # Game data
        t.integer :steam_id, null: false
        t.integer :community_hub_id
        t.string :name
        t.string :tags, default: '[]', null: false
        t.string :genre
        t.text :summary
        t.datetime :released_at
        t.string :text_release_date
        t.string :developer
        t.string :publisher

        # Media
        t.string :thumbnail
        t.text :videos, default: '[]', null: false
        t.text :images, default: '[]', null: false

        # Price
        t.integer :price
        t.integer :sale_price

        # Reviews
        t.integer :reviews_ratio
        t.integer :reviews_count
        t.integer :positive_reviews_count
        t.integer :negative_reviews_count
        t.text :positive_reviews, default: '[]', null: false
        t.text :negative_reviews, default: '[]', null: false


        # Other data
        t.integer :dlc_count
        t.integer :achievements_count
        t.string :audio_languages, default: '[]', null: false
        t.string :subtitles_languages, default: '[]', null: false
        t.integer :metacritic
        t.string :esrb_rating
        t.boolean :early_access
        t.text :system_requirements

        # Flag values
        t.integer :players, default: 0, null: false
        t.integer :controller_support, default: 0, null: false
        t.integer :features, default: 0, null: false
        t.integer :platforms, default: 0, null: false
        t.integer :vr_platforms, default: 0, null: false
        t.integer :vr_mode, default: 0, null: false
        t.integer :vr_controllers, default: 0, null: false

        # Scraping dates
        t.datetime :game_scraped_at
        t.datetime :list_scraped_at
        t.datetime :reviews_scraped_at
      end

      add_index :steam_games, :steam_id, unique: true
    end
  end
end
