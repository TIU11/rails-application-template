# frozen_string_literal: true

module Type

  # Convert localized date string to Date object. This takes I18n formatted date strings
  # (e.g. in form text inputs) and casts them back to Date objects when writing the attribute.
  #
  # See ActiveModel::Type::Date for original, which attempts to parse the Date string, causing
  # the months and days swap if input is in "%m/%d/%Y" format.
  #
  class Role < ActiveRecord::Type::String

    def serialize(value)
      value = cast_value(value) unless value.is_a? ::Role
      value.name if value.is_a? ::Role
    end

    private

      def cast_value(value)
        return if value.blank?
        case value
        when ::String, ::Symbol
          ::Role[value] || value
        when ::Role
          value
        end
      end

  end

end
