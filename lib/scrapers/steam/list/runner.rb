require 'json'
require_relative 'page_processor'
require_relative 'initial_page_processor'

module Scrapers
  module Steam
    module List
      SCHEMA = JSON.parse(File.read("#{__dir__}/schema.json"))

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
          Scrapers.logger.ln "For #{@config[:url]}"
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
              Scrapers.logger.ln "Page #{count}/#{urls.count} | #{games.size} games in page, #{total_games} total"
            end
          end

          loader.run
        end

        def report_message
          if @report.output
            "#{@report.output.size} games found"
          end
        end
      end
    end
  end
end
