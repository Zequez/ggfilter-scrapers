require 'json'
require 'uri'
require 'recursive-open-struct'

module Scrapers
  module Oculus
    SCHEMA = JSON.parse(File.read("#{__dir__}/schema.json"))

    class Runner
      def initialize(config = {})
        @config = {
          game_id: nil,
          section_id: 1736210353282450,
          access_token: ENV['OCULUS_ACCESS_TOKEN'],
          graph_endpoint: 'https://graph.oculus.com/graphqlbatch?forced_locale=en_US'
        }.merge(config)

        @report = Scrapers::ScrapReport.new('oculus_runner')
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

      def run
        @report.start


        if scrap_all?
          data = request(all_games_query)
          output = data[@config[:section_id].to_s]['all_paged']['edges'].map do |item|
            extract_game item['node']
          end
        else
          data = request(single_game_query)
          output = extract_game data[@config[:game_id].to_s]
        end

        @report.finish
        @report.output = output
        @report
      end

      def remap_array(arr, hash)
        arr.map{ |v| hash[v] || v }
      end

      def extract_game(g)
        g = RecursiveOpenStruct.new g

        {
          oculus_id: g.id.to_i,
          name: g.display_name.strip,
          price: g.current_offer.price.offset_amount.to_i,
          price_was: g.current_offer.strikethrough_price &&
            g.current_offer.strikethrough_price.offset_amount.to_i,
          summary: g.display_short_description,
          version: g.latest_supported_binary.version,
          category: g.category_name,
          genres: g.genre_names,
          languages: g.supported_in_app_languages.map{|o| o['name']},
          released_at: Time.at(g.release_date),
          age_rating: g.age_rating && g.age_rating.category_name,
          developer: g.developer.name.strip,
          publisher: g.publisher_name.strip,
          vr_mode: g.supported_player_modes,
          vr_tracking: g.supported_tracking_modes,
          vr_controllers: g.supported_input_devices,
          players: g.user_interaction_modes,
          comfort: g.comfort_rating,
          internet: g.internet_connection,
          sysreq_hdd: g.latest_supported_binary.required_space.to_i,
          sysreq_cpu: g.recommended_processor,
          sysreq_gpu: g.recommended_graphics,
          sysreq_ram: g.recommended_memory_gb,
          website_url: g.website_url
        }
      end

      def request(query)
        response = Typhoeus.post(@config[:graph_endpoint],
          headers: {'Content-Type'=> 'application/x-www-form-urlencoded'},
          body: URI.encode_www_form(payload(query))
        )
        result, _ = response.body.split("\n")
        JSON.parse(result)['q1']['response']
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
