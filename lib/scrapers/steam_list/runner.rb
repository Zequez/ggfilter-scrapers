# Responsabilities:
#  - Load the required games from the database
#  - Perform the scraping of the games with the URLs and the processors
#  - Save the games
#  - Report any issues like invalid data

class Scrapers::SteamList::Runner < Scrapers::BaseRunner
  def self.options
    {
      on_sale: false,
      all_games_url: 'http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&page=1',
      on_sale_url: 'http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&page=1&specials=1'
    }
  end

  def run!
    Scrapers.logger.info "For " + (sale? ? 'games on sale' : 'all games')

    url = sale? ? options[:on_sale_url] : options[:all_games_url]
    @on_sale_ids = []
    @loader = Scrapers::Loader.new(Scrapers::SteamList::PageProcessor, url)
    @loader.scrap do |scrap_request|
      scrap_request.output.each do |game_data|
        game = Game.find_by_steam_id(game_data[:id])
        data_process(game_data, game)
      end
    end

    if sale?
      updated_count = Game.where.not(id: @on_sale_ids).update_all(steam_sale_price: nil)
      on_sale_count = @on_sale_ids.size
      Scrapers.logger.info "SteamList #{updated_count} items no longer on sale! #{on_sale_count} on sale!"
    end
  end

  private

  def data_process(data, game)
    processor = Scrapers::SteamList::DataProcessor.new(data, game)
    game = processor.process
    was_new = game.new_record?
    game.steam_list_scraped_at = Time.now
    game.save!
    log_game(game, was_new)
    @on_sale_ids.push(game.id) if game.steam_sale_price
  end

  def sale?
    @options[:on_sale]
  end

  def log_game(game, was_new)
    log_text = game_log_text(game)
    Scrapers.logger.ln was_new ? log_text.green : log_text
  end
end
