module Scrapers
  class CustomLogger < Logger
    @@colors = {
      fatal: :red,
      error: :red,
      warn: :red,
      info: :blue
    }

    def format_message(severity, timestamp, progname, msg)
      output = "#{timestamp.iso8601} #{severity} #{msg}\n"
      sev = severity.downcase.to_sym

      if !(msg =~ /^\\e\[0;/) and @@colors[sev]
        output = output.send(@@colors[sev])
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

    def print(msg)
      self << msg
    end
  end
end
