class Scrapers::SteamGame::DataProcessor
  def initialize(data, game)
    @data = data.clone
    @game = game
    @errors = []
  end

  attr_reader :errors

  def process
    @data[:audio_languages] = convert_languages(@data[:audio_languages])
    @data[:subtitles_languages] = convert_languages(@data[:subtitles_languages])
    @data[:controller_support] = @data[:controller_support] && @data[:controller_support].first || :no
    @game.assign_attributes(@data)
    @game
  end

  EXTRA_LANGUAGES = {
    'Simplified Chinese' => 'zh-CN', # Technically correct zh-HANS
    'Traditional Chinese' => 'zh-TW' # Technically correct zh-HANT
  }

  def convert_languages(languages)
    return [] unless languages

    languages.map do |language|
      lang, country = language.split('-')

      if ( lang_abbr = EXTRA_LANGUAGES[lang] )
        lang_abbr
      else
        lang_abbr = lang && I18nData.language_code(lang)
        country_abbr = country && I18nData.country_code(country)

        raise "Unknown language #{lang}" if lang and not lang_abbr
        raise "Unknown country #{country}" if country and not country_abbr

        lang_abbr = lang_abbr.downcase

        if lang_abbr and country_abbr
          "#{lang_abbr}-#{country_abbr}"
        else
          lang_abbr
        end
      end
    end
  end
end
