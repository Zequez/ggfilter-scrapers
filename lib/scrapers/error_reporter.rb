require 'yaml'

module Scrapers
  class ErrorReporter
    def initialize(scrap_abort_error, scraper_name, options = {})
      raise ArgumentError unless scrap_abort_error.is_a? Errors::ScrapAbortError
      @error = scrap_abort_error
      @scraper_name = scraper_name
      @options = {
        filesystem: 'log/scrap_errors',
        email: nil
      }.merge(options)
      @time = Time.now
    end

    def commit
      save if @options[:filesystem]
      email if @options[:email]
    end

    private

    def timestamp
      @time.strftime('%Y%m%d-%H%M%S')
    end

    def simplified_url
      @error.url
        .sub(/^https?:\/\//, '')
        .sub(/\?.*$/, '')
        .gsub(/[\x00\/\\:\*\?\"<>\|.]/, '_')

    end

    def source_backtrace
      bt = @error.cause.original_e ? @error.cause.original_e.backtrace : @error.cause.backtrace
      bt ? bt.join("\n") : nil
    end

    def report_object
      {
        url: @error.url,
        code: @error.response.code,
        time: @time,
        message: @error.message,
        original_message: @error.cause.original_e && @error.cause.original_e.message,
        backtrace: source_backtrace,
        request_headers: @error.request.options[:headers],
        response_headers: @error.response.headers
      }
    end

    def save
      file_name = "#{timestamp}_#{@scraper_name}_#{simplified_url}"
      file_path = "#{Scrapers.app_root}/#{@options[:filesystem]}"

      FileUtils.mkdir_p file_path

      File.write("#{file_path}/#{file_name}.yml", YAML.dump(report_object))
      File.write("#{file_path}/#{file_name}.html", @error.html.force_encoding('utf-8'))
    end

    def email

    end
  end
end
