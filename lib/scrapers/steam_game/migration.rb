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
            [:reviews_positive_count, :integer],
            [:reviews_negative_count, :integer]
          ].each do |(column, type)|
            add_column @table_name, column, type
          end
        end
      end
    end
  end
end
