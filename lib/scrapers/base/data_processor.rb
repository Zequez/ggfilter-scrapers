module Scrapers::Base
  class DataProcessor
    def errors
      @errors ||= []
    end

    def initialize(data, model)
      @data = data
      @game = @model = model
    end

    def process
      @model.assign_attributes(@data)
      @model
    end
  end
end
