class Scrapers::SteamGame::DataProcessor
  def initialize(data, game)
    @data = data.clone
    @game = game || Game.new
    @errors = []
  end

  attr_reader :errors

  def process
    @data[:audio_languages] = convert_languages(@data[:audio_languages])
    @data[:subtitles_languages] = convert_languages(@data[:subtitles_languages])
    @data[:controller_support] = @data[:controller_support].first
    @game.assign_attributes(@data)
    @game
  end

  LANGUAGES = {
    'English' => 'en',
    'Spanish' => 'es',
    'Portuguese' => 'pt'
  }

  COUNTRIES = {
    'Brazil' => 'BR'
  }

  def convert_languages(languages)
    languages.map do |language|
      lang, country = language.split('-')

      lang_abbr = LANGUAGES[lang]
      country_abbr = COUNTRIES[country]

      raise "Unknown language #{lang}" if lang and not lang_abbr
      raise "Unknown country #{country}" if country and not country_abbr

      if lang_abbr and country_abbr
        "#{lang_abbr}-#{country_abbr}"
      else
        lang_abbr
      end
    end
  end
end
