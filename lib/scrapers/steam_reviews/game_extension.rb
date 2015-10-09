module Scrapers::SteamReviews::GameExtension
  extend ActiveSupport::Concern

  included do
    serialize :positive_steam_reviews
    serialize :negative_steam_reviews
  end
end
