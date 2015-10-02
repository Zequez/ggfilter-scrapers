module Scrapers
  class BaseMigration < ActiveRecord::Migration
    def initialize(*args, table_name: nil)
      @table_name = table_name
      super(*args)
    end
  end
end
