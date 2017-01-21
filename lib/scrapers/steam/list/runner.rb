# Responsabilities:
#  - Load the required games from the database
#  - Perform the scraping of the games with the URLs and the processors
#  - Save the games
#  - Report any issues like invalid data

module Scrapers
  module Steam
    module List
      class Runner < Scrapers::Base::Runner
        def processor; PageProcessor end
        def self.options
          super.merge({
            on_sale: false,
            all_games_url: 'http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&page=1',
            on_sale_url: 'http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&page=1&specials=1',
            resource_class: SteamGame
          })
        end
        def name; 'steam_list' end

        def urls
          [sale? ? options[:on_sale_url] : options[:all_games_url]]
        end

        def run!
          Scrapers.logger.info "For " + (sale? ? 'games on sale' : 'all games')

          @new_games = 0
          @found_games = 0
          @on_sale_ids = []
          scrap do |games_data|
            games_data.each do |game_data|
              game = resource_class.find_by_steam_id(game_data[:id])
              data_process(game_data, game)
            end
          end

          if sale?
            updated_count = resource_class.where.not(id: @on_sale_ids).update_all(sale_price: nil)
            on_sale_count = @on_sale_ids.size
            Scrapers.logger.info "SteamList #{on_sale_count}/#{on_sale_count + updated_count} items on sale!"
          end
        end

        def report_msg
          if sale?
            "#{@new_games} new games | #{@found_games} games on sale"
          else
            "#{@new_games} new games | #{@found_games} games found"
          end
        end

        private

        def data_process(data, game)
          processor = DataProcessor.new(data, game, resource_class)
          game = processor.process
          was_new = game.new_record?
          @found_games += 1
          @new_games += 1 if was_new
          game.list_scraped_at = Time.now
          game.save!
          log_game(game, was_new)
          @on_sale_ids.push(game.id) if game.sale_price
        end

        def sale?
          @options[:on_sale]
        end

        def log_game(game, was_new)
          log_text = game_log_text(game)
          Scrapers.logger.ln was_new ? log_text.green : log_text
        end
      end
    end
  end
end
