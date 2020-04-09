# frozen_string_literal: true

# Where the I18n library should search for translation files
# Loads locales in nested subfolders, not just in the default directory
Rails.application.config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.{rb,yml}')]

# Make missing translations fail loudly in development and test.
# See https://robots.thoughtbot.com/better-tests-through-internationalization
if Rails.env.development? || Rails.env.test?
  I18n.exception_handler = lambda do |_exception, _locale, key, options|
    scoped_key = [*options&.dig(:scope), key].join '.'
    raise "missing translation: #{scoped_key}"
  end
end
