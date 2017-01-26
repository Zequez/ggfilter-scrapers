require 'json'
require 'uri'
require 'recursive-open-struct'

module Scrapers
  module Oculus
    SCHEMA = JSON.parse(File.read("#{__dir__}/schema.json"))

    class Runner < BasicRunner
      def initialize(config = {})
        @config = {
          game_id: nil,
          section_id: 1736210353282450,
          access_token: ENV['OCULUS_ACCESS_TOKEN'],
          graph_endpoint: 'https://graph.oculus.com/graphqlbatch?forced_locale=en_US'
        }.merge(config)

        @report = Scrapers::ScrapReport.new
      end

      def scrap_all?
        @config[:game_id].nil?
      end

      def single_game_query
        (get_query('single_game') + get_query('game_fragment'))
          .sub('GAME_ID', @config[:game_id].to_i.to_s)
      end

      def all_games_query
        (get_query('all_games') + get_query('game_fragment'))
          .sub('SECTION_ID', @config[:section_id].to_i.to_s)
      end

      def run!
        if scrap_all?
          data = request(all_games_query)
          output = PageProcessor.new.extract_games data[@config[:section_id].to_s]
          @report.scraper_report = "#{output.size} games found in the Oculus Store"
        else
          data = request(single_game_query)
          output = PageProcessor.new.extract_game data[@config[:game_id].to_s]
        end

        @report.output = output
      end

      def request(query)
        response = Typhoeus.post(@config[:graph_endpoint],
          headers: {'Content-Type'=> 'application/x-www-form-urlencoded'},
          body: URI.encode_www_form(payload(query))
        )

        result, _ = response.body.split("\n")
        result = JSON.parse(result)
        if result['error']
          raise result['error']['message'].to_s
        else
          result['q1']['response']
        end
      end

      def payload(query)
        {
          access_token: @config[:access_token],
          batch_name: 'Queries',
          method: 'GET',
          queries: JSON.dump({
            q1: {
              priority: 0,
              q: query
            }
          }),
          response_format: 'json',
          scheduler: 'phased'
        }
      end

      def get_query(name)
        File.read("#{__dir__}/#{name}.gql")
      end
    end
  end
end
