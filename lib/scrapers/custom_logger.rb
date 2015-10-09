module Scrapers
  class CustomLogger < Logger
    @@colors = {
      fatal: :red,
      error: :red,
      warn: :orange,
      info: :blue
    }

    def format_message(severity, timestamp, progname, msg)
      output = "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
      sev = severity.downcase.to_sym

      if !(msg =~ /^\\e\[0;/) and @@colors[sev]
        output = output.send(@@colors[sev])
      end

      if sev == :error or msg == :fatal
        errors_only_file << output
      end

      output
    end

    def l(msg)
      self << "#{msg.inspect}\n"
    end

    def la(msg)
      self << "#{msg.ai}\n"
    end

    def ln(msg)
      self << "#{msg}\n"
    end

    def errors_only_file
      @error_logger ||= begin
        logfile = File.open("#{Scrapers.app_root}/log/scrapers_errors.log", 'a')  # create log file
        logfile.sync = true  # automatically flushes data to file
        Logger.new(logfile)
      end
    end

    def store_error_page(scrap_request, exception)
      backtrace = exception.backtrace.join("\n")
      time = Time.now.to_i
      sanitized_url = scrap_request.url.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')

      file_name = "#{time}_#{sanitized_url}"
      file_path = "#{Scrapers.app_root}/log/error_pages"

      FileUtils.mkdir_p file_path
      File.write("#{file_path}/#{file_name}.html", scrap_request.response.body)
      File.write("#{file_path}/#{file_name}.backtrace", backtrace)

      self.error "Stored error page and backtrace #{file_name}"
      errors_only_file << backtrace + "\n"
    end
  end
end
