module Scrapers
  module SteamGame
    class Migration
      class M1 < BaseMigration
        def change
          [
            [:tags, :string],
            [:genre, :string],
            [:dlc_count, :integer],
            [:steam_achievements_count, :integer],
            [:audio_languages, :string],
            [:subtitles_languages, :string],
            [:metacritic, :integer],
            [:esrb_rating, :string],
            [:videos, :text],
            [:images, :text],
            [:summary, :text],
            [:early_access, :boolean],
            [:system_requirements, :text],
            [:players, :integer],
            [:controller_support, :integer],
            [:features, :integer],
            [:positive_steam_reviews_count, :integer],
            [:negative_steam_reviews_count, :integer],
            [:steam_game_scraped_at, :datetime]
          ].each do |(column, type)|
            add_column @table_name, column, type
          end
        end
      end
    end
  end
end
