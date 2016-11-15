module ProcessorSpecHelper
  def scrap(page_url, headers = {}, &add_to_queue)
    response = Typhoeus.get(page_url, headers: headers)
    add_to_queue ||= lambda{|url|}
    scrap_request = Scrapers::RootScrapRequest.new(page_url, lambda{ |all_data, data| })
    scrap_request.set_response response
    processor_class.new(scrap_request, &add_to_queue).process_page
  end
end
