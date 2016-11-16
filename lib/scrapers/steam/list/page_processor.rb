# Output
# Array of
#  :id
#  :name
#  :price
#  :sale_price
#  :released_at
#  :platforms
#  :reviews_count
#  :reviews_ratio
#  :thumbnail
module Scrapers::Steam::List
  class PageProcessor < Scrapers::Base::PageProcessor
    regexp %r{^http://store\.steampowered\.com/search/results}

    def inject(data)
      data ||= []
      data += @data
    end

    def process_page
      data = []

      css!('#search_result_container')

      css('.search_result_row').each do |a|
        game = {}

        game[:id] = read_id(a)
        game[:name] = read_name(a)
        game[:price], game[:sale_price] = read_prices(a)
        game[:released_at] = read_released_at(a)
        game[:platforms] = read_platforms(a)
        game[:reviews_count], game[:reviews_ratio] = read_reviews(a)
        game[:thumbnail] = read_thumbnail(a)

        data << game
      end

      pagination = @doc.search('.search_pagination_right')
      if pagination.text.strip =~ /^1\b/ # if we are parsing the first page
        last_page_e = pagination.search('a:not(.pagebtn)').last
        if last_page_e
          last_page_link = last_page_e['href'].sub(%r{/search/\?}, '/search/results?')
          last_page_number = Integer(last_page_link.scan(/page=(\d+)/).flatten.first)
          (2..last_page_number).each do |n|
            page_link = @url.sub("page=1", "page=#{n}")
            add_to_queue page_link
          end
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

    def read_released_at(a)
      date = css!('.search_released', a).text
      if date.blank?
        nil
      else
        begin
          Time.parse(a.search('.search_released').text)
        rescue ArgumentError
          nil
        end
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
        tooltip = reviews_e['data-store-tooltip']
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
