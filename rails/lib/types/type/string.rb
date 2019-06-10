# frozen_string_literal: true

module Type
  # * +squish+ if true, squish value when casting
  # * +strip+ if true, strip value when casting
  # * +nilify_blank+ if true, set blank value to nil when casting
  class String < ActiveModel::Type::String

    def initialize(precision: nil, limit: nil, scale: nil, strip: false, squish: false, nilify_blank: false)
      @strip = strip
      @squish = squish
      @nilify_blank = nilify_blank
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
        return unless value

        if @squish
          value = value.squish
        elsif @strip
          value = value.strip
        end

        value = nil if @nilify_blank && value.blank?

        value
      end
  end
end
