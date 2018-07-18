# frozen_string_literal: true

module Type
  class String < ActiveModel::Type::String

    def initialize(precision: nil, limit: nil, scale: nil, strip: false, squish: false)
      @strip = strip
      @squish = squish
      super(precision: precision, limit: limit, scale: scale)
    end

    private

      def cast_value(value)
        if @squish
          value.strip
        elsif @strip
          value.strip
        else
          value
        end
      end
  end
end
