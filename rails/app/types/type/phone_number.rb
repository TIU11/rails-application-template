# frozen_string_literal: true

module Type

  # A normalized phone number using PhonyRails.
  # Formatted as an [E.164](https://en.wikipedia.org/wiki/E.164) number
  class PhoneNumber < ActiveRecord::Type::String

    COUNTRY_CODE = 'US'

    def serialize(value)
      cast_value(value)
    end

    private

      def cast_value(value)
        PhonyRails.normalize_number(value, default_country_code: COUNTRY_CODE)
      end
  end
end
