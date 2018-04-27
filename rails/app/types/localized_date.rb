# frozen_string_literal: true

# Convert localized date string to Date object. This takes I18n formatted date strings
# (e.g. in form text inputs) and casts them back to Date objects when writing the attribute.
#
# See ActiveModel::Type::Date for original, which attempts to parse the Date string, causing
# the months and days swap if input is in "%m/%d/%Y" format.
#
class LocalizedDate < ActiveRecord::Type::Date

  # TODO: configurable format instead of just :default
  FORMAT = :default

  def format
    I18n.translate("date.formats.#{FORMAT}")
  end

  private

    def cast_value(value)
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

end
