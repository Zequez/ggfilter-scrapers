module Scrapers
  module SteamReviews
    module Migration
      class M1 < BaseMigration
        def change
          [
            [:positive_steam_reviews, :text],
            [:negative_steam_reviews, :text],
            [:steam_reviews_scraped_at, :datetime]
          ].each do |(column, type)|
            add_column @table_name, column, type
          end
        end
      end
    end
  end
end
