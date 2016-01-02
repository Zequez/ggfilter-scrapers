module Scrapers::SteamGame::GameExtension
  extend ActiveSupport::Concern

  included do
    flag_column :players, {
      single_player:  0b0001,
      multi_player:   0b0010,
      co_op:          0b0100,
      local_co_op:    0b1000
    }

    def controller_support_enum
      { no: 1, partial: 2, full: 3 }
    end

    def controller_support=(support)
      write_attribute :controller_support, controller_support_enum[support.to_sym]
    end

    def controller_support
      controller_support_enum.invert[read_attribute :controller_support]
    end

    # enum controller_support: [:no, :partial, :full]#, _suffix: true # Edge Rails :c

    flag_column :features, {
      steam_achievements:  0b000001,
      steam_trading_cards: 0b000010,
      # vr_support:          0b000100,
      steam_workshop:      0b001000,
      steam_cloud:         0b010000,
      valve_anti_cheat:    0b100000
    }

    flag_column :vr, {
      vive:   0b001,
      oculus: 0b010,
      open:   0b100
    }

    serialize :tags, JSON
    serialize :audio_languages
    serialize :subtitles_languages
    serialize :videos
    serialize :images
    serialize :system_requirements
  end
end
