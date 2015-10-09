class Scrapers::BaseRunner
  def self.options
    {}
  end

  def initialize(options = {})
    @options = self.class.options.merge(options)
  end

  def run
    log_text = "#{self.class} running!"
      .colorize(:color => :black, :background => :yellow)
    Scrapers.logger.info log_text

    start_time = Time.now

    run!

    elapsed_time = (Time.now - start_time)
    elapsed_minutes = (elapsed_time / 60).floor
    elapsed_seconds = (elapsed_time % 60).floor

    log_text = "#{self.class} finished! Time elapsed: #{elapsed_minutes}m #{elapsed_seconds}s"
      .colorize(:color => :black, :background => :light_yellow)
    Scrapers.logger.info log_text
  end

  def game_log_text(game)
    log_id = game.steam_id.to_s.ljust(10)
    name = game.name.blank? ? '<No name>' : game.name
    "#{log_id} #{name}"
  end
  
  def options
    @options
  end
end
