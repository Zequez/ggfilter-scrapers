require 'simple_flaggable_column'

module WithModelExtended
  def with_model_extended(name, extensions = [], migrations = [])
    extensions = [extensions].flatten
    migrations = [migrations].flatten

    with_model name do
      table do |t|
      end

      model do
        include SimpleFlaggableColumn
        extensions.each do |extension|
          include extension
        end
      end
    end

    before(:each) do
      table_name = name.to_s.constantize.table_name
      migrations.each do |migration|
        migration.new(table_name: table_name).migrate(:up)
      end
    end
  end
end
