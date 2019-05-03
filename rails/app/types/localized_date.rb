# frozen_string_literal: true

# Convert localized date string to Date object. This takes I18n formatted date strings
# (e.g. in form text inputs) and casts them back to Date objects when writing the attribute.
#
# See ActiveModel::Type::Date for original, which attempts to parse the Date string, causing
# the months and days swap if input is in "%m/%d/%Y" format.
#
class LocalizedDate < ActiveRecord::Type::Date

  FORMAT_STRING_EXPR = /(?<=%)(?<flag>[-_0^#])?(?<width>\d)?/ # Full specifier is: %<flag><width><modifier><conversion>

  def initialize(format: default_format)
    @format_string = safe_format_string(format)
  end

  # Deserialize db value using Date::DATE_FORMATS[:db]
  def deserialize(value)
    cast_value(value, format: Date::DATE_FORMATS[:db]) unless value.nil?
  end

  private

    def cast_value(value, format: @format_string)
      if value.is_a?(::String)
        return if value.empty?

        Date.strptime(value, format)
      elsif value.respond_to?(:to_date)
        value.to_date
      else
        value
      end
    rescue ArgumentError
      nil
    end

    def default_format
      I18n.translate("date.formats.default")
    end

    # Date.strptime doesn't support flags and width, so remove them.
    # See https://ruby-doc.org/stdlib/libdoc/date/rdoc/Date.html#method-c-strptime
    def safe_format_string(value)
      value.gsub FORMAT_STRING_EXPR, ''
    end
end
