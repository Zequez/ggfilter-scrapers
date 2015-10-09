module Scrapers
  module SteamList
    class Migration
      class M1 < BaseMigration
        def change
          [
            [:name, :string],
            [:steam_name, :string],
            [:steam_id, :integer],
            [:steam_price, :integer],
            [:steam_sale_price, :integer],
            [:steam_reviews_ratio, :integer],
            [:steam_reviews_count, :integer],
            [:steam_thumbnail, :string],
            [:released_at, :datetime],
            [:steam_list_scraped_at, :datetime]
          ].each do |(column, type)|
            add_column @table_name, column, type
          end

          add_column(@table_name, :platforms, :integer, default: 0, null: false)
        end
      end
    end
  end
end
