# Responsabilities:
#  - Load the required games from the database
#  - Perform the scraping of the games with the URLs and the processors
#  - Save the games
#  - Report any issues like invalid data

require_relative 'page_processor'
require_relative 'initial_page_processor'

module Scrapers
  module Steam
    module List
      URLS = {
        all: 'http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&page=1',
        on_sale: 'http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&page=1&specials=1'
      }
      
      class Runner < Scrapers::BasicRunner
        def initialize(config = {})
          @config = {
            url: :all
          }.merge(config)

          @url = List::URLS[@config[:url]] || @config[:url]
        end

        def run!
          Scrapers.logger.info "For #{@config[:url]}"
          @report.output = []

          first_page = Typhoeus.get(@url)
          urls = InitialPageProcessor.new(first_page.body, @url).process_page

          count = 0
          urls.each do |url|
            queue(url) do |response|
              games = PageProcessor.new(response.body).process_page
              @report.output.concat games

              count += 1
              total_games = @report.output.size
              Scrapers.logger.info "Page #{count}/#{urls.count} | #{games.size} games in page, #{total_games} total"
            end
          end

          loader.run
        end

        def report_message
          if @report.output
            "#{@report.output.size} games found"
          end
        end

        # def report_msg
        #   if sale?
        #     "#{@new_games} new games | #{@found_games} games on sale"
        #   else
        #     "#{@new_games} new games | #{@found_games} games found"
        #   end
        # end

        # private

        # def data_process(data, game)
        #   processor = DataProcessor.new(data, game, resource_class)
        #   game = processor.process
        #   was_new = game.new_record?
        #   @found_games += 1
        #   @new_games += 1 if was_new
        #   game.list_scraped_at = Time.now
        #   game.save!
        #   @report.output.push(game)
        #   log_game(game, was_new)
        #   @on_sale_ids.push(game.id) if game.sale_price
        # end
        #
        # def sale?
        #   @options[:on_sale]
        # end
        #
        # def log_game(game, was_new)
        #   log_text = game_log_text(game)
        #   Scrapers.logger.ln was_new ? log_text.green : log_text
        # end
      end
    end
  end
end
