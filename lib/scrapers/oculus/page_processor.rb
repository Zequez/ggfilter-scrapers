module Scrapers
  module Oculus
    class PageProcessor
      def extract_games(object)
        object['all_paged']['edges'].map do |item|
          extract_game item['node']
        end
      end

      def extract_game(g)
        g = RecursiveOpenStruct.new g

        {
          oculus_id: g.id.to_i,
          name: g.display_name.strip,
          price: g.current_offer.price.offset_amount.to_i,
          price_regular: g.current_offer.strikethrough_price &&
            g.current_offer.strikethrough_price.offset_amount.to_i,
          summary: g.display_short_description,
          version: g.latest_supported_binary.version,
          category: g.category_name,
          genres: g.genre_names,
          languages: g.supported_in_app_languages.map{|o| o['name']},
          released_at: Time.at(g.release_date).iso8601,
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
          website_url: g.website_url,
          rating_1: g.quality_rating_histogram_aggregate[0]['count'],
          rating_2: g.quality_rating_histogram_aggregate[1]['count'],
          rating_3: g.quality_rating_histogram_aggregate[2]['count'],
          rating_4: g.quality_rating_histogram_aggregate[3]['count'],
          rating_5: g.quality_rating_histogram_aggregate[4]['count'],
          thumbnail: g.cover_landscape_image.uri,
          screenshots: g.screenshots.map{ |s| s['uri'] },
          trailer_video: g.video_trailer && g.video_trailer.uri,
          trailer_thumbnail: g.video_trailer && g.video_trailer.thumbnail && g.video_trailer.thumbnail.uri
        }
      end
    end
  end
end
