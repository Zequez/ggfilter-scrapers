require 'json'

module Scrapers::Steam::Game
  SCHEMA = JSON.parse(File.read("#{__dir__}/schema.json"))

  class Runner < Scrapers::BasicRunner
    def loader_options
      {headers: {
        'Cookie' => 'birthtime=724320001; mature_content=1; fakeCC=US'
      }}
    end

    def initialize(steam_ids: [])
      @steam_ids = steam_ids
    end

    URL = 'http://store.steampowered.com/app/%s'

    def continue_parsing?(response)
      if response.headers['Location']
        to = response.headers['Location']
        report.add_warning "Game #{response.request.url} got redirected to #{to}"
        false
      else
        super
      end
    end

    def run!
      report.output = []

      @steam_ids.each do |steam_id|
        url = self.class::URL % steam_id
        queue(url) do |response|
          data = PageProcessor.new(response.body).process_page
          if data
            data[:steam_id] = steam_id
            report.output.push data
            log_game(data)
          else
            report.add_warning "Page processor couldn't extract data | #{url}"
          end
        end
      end

      loader.run
    end

    def report_message
      if report.output
        "#{report.output.size} games processed"
      end
    end

    def log_game(game)
      left = "#{report.output.size} / #{@steam_ids.size}"
      log_id = game[:steam_id].to_s.ljust(10)
      name = game[:name].blank? ? '<No name>' : game[:name]
      Scrapers.logger.ln "#{log_id} | #{name} | #{left}"
    end
  end
end
