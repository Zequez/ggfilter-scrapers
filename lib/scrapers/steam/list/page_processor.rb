module Scrapers::Steam::List
  class PageProcessor < Scrapers::Base::PageProcessor
    def process_page
      data = []

      css!('#search_result_container')

      css('.search_result_row').each do |a|
        game = {}

        game[:steam_id] = read_id(a)
        game[:name] = read_name(a)
        game[:price], game[:sale_price] = read_prices(a)
        game[:steam_published_at] = read_released_at(a)
        game[:text_release_date] = read_text_release_date(a)
        game[:platforms] = read_platforms(a)
        game[:reviews_count], game[:reviews_ratio] = read_reviews(a)
        game[:thumbnail] = read_thumbnail(a)

        if game[:steam_id] && (game[:price] || game[:text_release_date] || game[:steam_published_at])
          data << game
        end
      end

      data
    end

    def read_id(a)
      id = a['href'].scan(/app\/([0-9]+)/).flatten.first
      id ? Integer(id) : nil
    end

    def read_name(a)
      css!('.title', a).text.strip
    end

    def read_prices(a)
      text = css!('.search_price', a).text
      if text
        price, sale_price = text.strip.scan(/\$\d+(?:\.\d+)?|[^\0-9]+/).flatten
        price = price ? parse_price(price) : nil
        sale_price = parse_price(sale_price)
        [price, sale_price]
      else
        [nil, nil]
      end
    end

    def read_text_release_date(a)
      date = css!('.search_released', a).text
      if date.blank?
        nil
      else
        date
      end
    end

    def read_released_at(a)
      date = read_text_release_date(a)
      if date =~ /[a-z]{3} [0-9]{1,2}, [0-9]{4}/i
        begin
          Time.parse(date).iso8601
        rescue ArgumentError
          nil
        end
      else
        nil
      end
    end

    def read_platforms(a)
      platforms = []
      platforms.push(:win) if css('.platform_img.win', a).first
      platforms.push(:mac) if css('.platform_img.mac', a).first
      platforms.push(:linux) if css('.platform_img.linux', a).first
      platforms
    end

    def read_reviews(a)
      css!('.search_reviewscore', a)
      reviews_e = css('.search_review_summary', a).first
      if reviews_e
        tooltip = reviews_e['data-tooltip-html']
        tooltip.gsub(',', '').scan(/\d+/).map{|n| Integer(n)}.reverse
      else
        [0, 50]
      end
    end

    def read_thumbnail(a)
      img_e = css!('.search_capsule img', a).first
      img_e ? img_e['src'] : nil
    end

    def parse_price(price)
      return nil if price.nil?

      price = price.strip.sub(/^\$/, '')

      if price =~ /[[:digit:]]+(\.[[:digit:]]+)?/
        price = Integer((Float(price) * 100).round)
      else
        price = price.downcase
        means_its_free = ['free to play', 'play for free', 'free', 'third party', 'open weekend']
        if price =~ /free/ or means_its_free.include? price
          price = 0
        else
          price = nil
        end
      end

      price
    end
  end
end
