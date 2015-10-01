class Scrapers::BaseRunner
  def self.options
    {}
  end

  def initialize(options = {})
    @options = self.class.options.merge(options)
  end

  def options
    @options
  end
end
