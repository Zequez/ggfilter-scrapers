module Scrapers
  module Benchmarks
    class Migration
      class M1 < BaseMigration
        def self.table_name; :gpus; end

        def change
          add_column table_name, :name, :string
          add_column table_name, :value, :integer
        end
      end
    end
  end
end
