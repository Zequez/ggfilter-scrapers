module Scrapers
  class BaseMigration < ActiveRecord::Migration
    def initialize(*args, table_name: nil)
      @table_name = table_name
      super(*args)
    end

    def self.table_name; :games; end
    def table_name
      @table_name || self.class.table_name
    end
  end
end
