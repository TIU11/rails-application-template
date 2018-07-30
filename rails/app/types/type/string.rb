# frozen_string_literal: true

module Type
  class String < ActiveModel::Type::String

    def initialize(precision: nil, limit: nil, scale: nil, strip: false, squish: false)
      @strip = strip
      @squish = squish
      super(precision: precision, limit: limit, scale: scale)
    end

    def serialize(value)
      super(value)
      apply_options(value)
    end

    private

      def cast_value(value)
        value = super(value)
        apply_options(value)
      end

      def apply_options(value)
        if value && @squish
          value.squish
        elsif value && @strip
          value.strip
        else
          value
        end
      end
  end
end
