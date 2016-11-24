require 'simple_flaggable_column'

module Scrapers::Steam
  class JSONWithSymbolsSerializer
    def self.load(str)
      str.nil? ? nil : JSON.parse(str, symbolize_names: true)
    end

    def self.dump(data)
      JSON.dump(data)
    end
  end

  class SteamGame < ActiveRecord::Base
    include SimpleFlaggableColumn

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

    flag_column :vr_platforms, {
      vive:   0b001,
      rift:   0b010
    }

    flag_column :vr_mode, {
      seated: 0b001,
      standing: 0b010,
      room_scale: 0b100
    }

    flag_column :vr_controllers, {
      tracked: 0b001,
      gamepad: 0b010,
      keyboard_mouse: 0b100
    }

    flag_column :platforms, {
      win:   0b001,
      mac:   0b010,
      linux: 0b100
    }

    serialize :tags, JSON
    serialize :audio_languages, JSON
    serialize :subtitles_languages, JSON
    serialize :videos, JSON
    serialize :images, JSON
    serialize :system_requirements, JSONWithSymbolsSerializer
    serialize :positive_reviews, JSON
    serialize :negative_reviews, JSON
  end
end
