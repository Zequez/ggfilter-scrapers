require 'simple_flaggable_column'

module WithModelExtended
  def with_model_extended(name, extension = nil, &block)
    with_model name do
      table do |t|
      end

      model do
        include SimpleFlaggableColumn
        if extension
          include extension
        end
      end
    end

    before(:each, &block)
  end
end
