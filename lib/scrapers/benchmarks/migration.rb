module Scrapers::Benchmarks
  class Migration < ActiveRecord::Migration
    def change
      create_table :gpus do |t|
        t.string :name
        t.string :value
      end
    end
  end
end
