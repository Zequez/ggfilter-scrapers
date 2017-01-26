module ProcessorSpecHelper
  def vcr_processor_request(processor_class, url, loader_options = {}, &cb)
    loader = Scrapers::Loader.new(loader_options)
    processor = processor_class.new(url, loader)
    cb ||= proc{}
    result = nil
    processor.load do |output|
      cb.call(output)
      result = output
    end
    loader.run{} # blocking
    return result
  end

  def page_processor_for_html(processor_class, html, url = 'http://google.com')
    Typhoeus.stub(url).and_return(Typhoeus::Response.new(code: 200, body: html))
    loader = Scrapers::Loader.new
    processor = processor_class.new(url, loader)
    result = nil
    processor.load do |output|
      result = output
    end
    loader.run{} # blocking
  end
end
