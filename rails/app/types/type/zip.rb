# frozen_string_literal: true

# USPS ZIP code
module Type
  class Zip < ActiveModel::Type::String

    def serialize(value)
      super(value)
      transform(value)
    end

    private

      def cast_value(value)
        value = super(value)
        transform(value)
      end

      def transform(value)
        value.gsub!(/\s+/, "")
        value.insert(5, '-') if value.length == 9 && !value.match?(/-/)
        value
      end
  end
end
