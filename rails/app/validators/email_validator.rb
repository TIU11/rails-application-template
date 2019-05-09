# frozen_string_literal: true

# TODO: Consider improving with:
# * http://my.rails-royce.org/2010/07/21/email-validation-in-ruby-on-rails-without-regexp/
# * https://hackernoon.com/the-100-correct-way-to-validate-email-addresses-7c4818f24643#.cst8tslbp
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.match?(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)

    record.errors[attribute] << (options[:message] || "is not an email")
  end
end
