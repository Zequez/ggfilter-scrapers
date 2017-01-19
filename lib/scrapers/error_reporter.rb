require 'yaml'
require 'sendgrid-ruby'
require "base64"

module Scrapers
  class ErrorReporter
    def initialize(scrap_abort_error, scraper_name, options = {})
      raise ArgumentError unless scrap_abort_error.kind_of? Errors::ScrapError
      @error = scrap_abort_error
      @scraper_name = scraper_name
      @options = {
        filesystem: 'log/scrap_errors',
        email: ENV['ERROR_REPORT_EMAIL'],
        email_from: 'noreply@ggfilter.com'
      }.merge(options)
      @time = Time.now
    end

    def commit
      save if @options[:filesystem]
      email if @options[:email]
    end

    private

    def is_loading_error
      @error.cause.kind_of? Errors::LoadingError
    end

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
      bt = @error.original_e ? @error.original_e.backtrace : @error.backtrace
      bt ? bt.join("\n") : nil
    end

    def report_object
      {
        url: @error.url,
        code: @error.response.code,
        time: @time,
        message: @error.message,
        original_message: @error.original_e && @error.original_e.message,
        backtrace: source_backtrace,
        request_headers: @error.request.options[:headers],
        response_headers: @error.response.headers
      }
    end

    def report_page
      @error.html.force_encoding('utf-8')
    end

    def file_name
      "#{timestamp}_#{@scraper_name}_#{simplified_url}"
    end

    def save
      file_path = "#{Scrapers.app_root}/#{@options[:filesystem]}"

      FileUtils.mkdir_p file_path

      File.write("#{file_path}/#{file_name}.yml", YAML.dump(report_object))
      File.write("#{file_path}/#{file_name}.html", report_page)
    end

    def email
      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])

      error_source = is_loading_error ? 'Loading error' : 'Processor error'
      time = @time.strftime('%Y-%m-%d %H:%M:%S')

      subject = "Error report #{@scraper_name} #{time} | #{error_source}"

      from = SendGrid::Email.new(email: @options[:email_from])
      to = SendGrid::Email.new(email: @options[:email])
      content = SendGrid::Content.new(type: 'text/plain', value: YAML.dump(report_object))
      mail = SendGrid::Mail.new(from, subject, to, content)

      attachment = SendGrid::Attachment.new
      attachment.content = Base64.strict_encode64(report_page)
      attachment.type = 'text/html'
      attachment.filename = "#{file_name}.html"
      mail.attachments = attachment

      sg.client.mail._('send').post(request_body: mail.to_json)
    end
  end
end
