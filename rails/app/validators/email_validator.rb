# frozen_string_literal: true

# Validates email format.
# * Doesn't check for RFC-5321 compliance
# * No dotless domains, prohibited per ICANN
# * Allows internationalized domain name (IDN)
#
# Regex Examples:
# * https://en.wikipedia.org/wiki/Email_address#Examples
# * https://github.com/binarylogic/authlogic/blob/master/doc/use_normal_rails_validation.md
# * https://github.com/heartcombo/devise/blob/main/lib/devise.rb#L116
# * https://github.com/truemail-rb/truemail#with-default-regex-pattern
#
# Reference:
# * SMTP specification
#   https://datatracker.ietf.org/doc/html/RFC5321
# * Technical specification for Top Level Domain Labels
#   https://tools.ietf.org/id/draft-liman-tld-names-00.html
# * New gTLD Dotless Domain Names Prohibited:
#   https://www.icann.org/en/announcements/details/new-gtld-dotless-domain-names-prohibited-30-8-2013-en
class EmailValidator < ActiveModel::EachValidator
  # /p{L} - letters in any language (for IDN support)
  EMAIL = /
    \A
    [^@\s]+              # mailbox
    @
    (?:[\p{L}0-9\-]+\.)+ # subdomains (can be IDN)
    [A-Z0-9\-]{2,63}     # TLD
    \z
  /ix.freeze

  def validate_each(record, attribute, value)
    return if value.match?(EMAIL)

    record.errors.add attribute, (options[:message] || :invalid)
  end
end
