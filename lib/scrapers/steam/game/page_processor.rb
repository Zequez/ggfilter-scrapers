module Scrapers::Steam::Game
  class PageProcessor < Scrapers::Base::PageProcessor
    def process_page
      game = {}

      return nil if css('#error_box .error').text =~ /unavailable in your region/

      game[:name] = css('.apphub_AppName').text.strip
      game[:tags] = css('.popular_tags a').map{ |a| a.text.strip }
      game[:dlc_count] = css('.game_area_dlc_name').size
      game[:achievements_count] = if ( sac = css('#achievement_block .block_title').first )
        Integer(sac.text.scan(/\d+/).flatten.first)
      else 0 end
      m = css('#game_area_metascore .score').first
      game[:metacritic] = (m && m.text && !(m.text =~ /NA/i)) ?
        Integer(m.text) : nil

      game[:esrb_rating] = if ( esrb = css('img[src*="images/ratings/esrb"]').first )
        esrb['src'].scan(/esrb_(\w+)/).flatten.first.to_sym
      else nil end
      game[:early_access] = !css('.early_access_header').empty?
      game[:audio_languages], game[:subtitles_languages] = read_languages
      game[:videos] = read_videos
      game[:images] = css('.highlight_strip_screenshot img').map{ |i| i['src'].sub(/.\d+x\d+\.jpg/, '.jpg') }
      game[:summary] = css!('.game_description_snippet').text.strip

      app_id = Integer(css!('link[rel="canonical"]').first['href'].scan(/app\/(\d+)/).flatten.first)
      game[:steam_id] = app_id

      community_hub_id = Integer(css!('.apphub_OtherSiteInfo a').first['href'].scan(/app\/(\d+)/).flatten.first)
      game[:community_hub_id] = community_hub_id # Sometimes is different from steam_id

      if css('.noReviewsYetTitle').text =~ /no reviews for this product/i
        game[:positive_reviews_count] = 0
        game[:negative_reviews_count] = 0
      else
        game[:positive_reviews_count] =
          Integer(css('[for="review_type_positive"] .user_reviews_count').text.gsub(/[(),]/, '')) || 0
        game[:negative_reviews_count] =
          Integer(css('[for="review_type_negative"] .user_reviews_count').text.gsub(/[(),]/, '')) || 0
      end

      game[:players] = detect_features(
        2 => :single_player,
        1 => :multi_player,
        36 => :online_multi_player,
        37 => :local_multi_player,
        9 => :co_op,
        38 => :online_co_op,
        39 => :local_co_op,
        24 => :shared_screen,
        27 => :cross_platform_multi
      )

      game[:controller_support] = detect_features(
        28 => :full,
        18 => :partial
      ).first || :no

      game[:features] = detect_features(
        22 => :steam_achievements,
        29 => :steam_trading_cards,
        31 => :vr,
        30 => :steam_workshop,
        23 => :steam_cloud,
        8  => :valve_anti_cheat
      )

      game[:vr_mode] = detect_vr_features(
        301 => :seated,
        302 => :standing,
        303 => :room_scale
      )

      game[:vr_controllers] = detect_vr_features(
        201 => :tracked,
        202 => :gamepad,
        203 => :keyboard_mouse
      )

      game[:vr_platforms] = detect_vr_features(
        101 => :vive,
        102 => :rift,
        103 => :osvr
      )

      game[:vr_only] = !!css('.notice_box_content').text.match(/Requires a virtual reality/i)

      game[:system_requirements] = read_system_requirements

      game[:genre] = game_link_text('/genre/')
      game[:developer] = game_link_text('developer=')
      game[:publisher] = game_link_text('publisher=')

      game[:released_at] = read_released_at

      game
    end

    def read_released_at
      date = css('.release_date .date').text()
      begin
        Time.parse(date).iso8601
      rescue ArgumentError
        nil
      end
    end

    def read_videos
      css('.highlight_movie script').map do |script|
        script.text.scan(%r{http://[^"]+movie\d+\.webm\?t=\d+}).first
      end
    end

    def read_languages
      langs_names = css('.game_language_options td:nth-child(1)').map{ |td| td.text.strip }
      audio_langs = css('.game_language_options td:nth-child(3)').map{ |td| !td.element_children.empty? }
      subs_langs = css('.game_language_options td:nth-child(4)').map{ |td| !td.element_children.empty? }
      [audio_langs, subs_langs].map do |arr|
        arr.each_with_index.map{|k, i| k ? langs_names[i] : nil }.compact
      end
    end

    def read_system_requirements
      win = css('.sysreq_content[data-os="win"]')
      min = list_to_hash win.at_css('.game_area_sys_req_leftCol, .game_area_sys_req_full')
      req = list_to_hash win.at_css('.game_area_sys_req_rightCol')

      {
        minimum: system_requirements_keyification(min),
        recommended: system_requirements_keyification(req)
      }
    end

    def list_to_hash(ul)
      Hash[
        ul
          .to_s
          .scan(/strong>([^<]+)<\/strong>([^<]+)/)
          .map{ |a| a.map{ |s| s.gsub(/^[:\s]+|[:\s]+$/, '') } }
      ]
    end

    def system_requirements_keyification(hash)
      keys = {
        processor: ['Processor', 'CPU'],
        memory: ['Memory', 'RAM'],
        video_card: ['Video Card', 'Graphics', 'Video'],
        disk_space: ['Hard Disk Space', 'Hard Drive', 'HDD', 'Storage']
      }

      Hash[keys.map do |k, vals|
        val = vals.detect{|v| hash[v] }
        [k, hash[val]]
      end]
    end

    def features
      @features ||= css('.game_area_details_specs .icon a')
        .map{ |a| a['href'].scan(/category[0-9]=(\d+)/).flatten.first }
        .compact
        .map{ |cat| Integer(cat) }
    end

    def vr_features
      @vr_features ||= css('.game_area_details_specs .icon a')
        .map{ |a| a['href'].scan(/vrsupport=(\d+)/).flatten.first }
        .compact
        .map{ |cat| Integer(cat) }
    end

    def detect_features(list, all_features = features)
      result = []
      list.each_pair do |key, value|
        result.push value if all_features.include?(key)
      end
      result
    end

    def detect_vr_features(list)
      detect_features(list, vr_features)
    end

    def game_link_text(link_match)
      a = css(".game_details a[href*=\"#{link_match}\"]").first
      a && a.text
    end
  end
end
