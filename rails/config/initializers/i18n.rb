# frozen_string_literal: true

# Where the I18n library should search for translation files
# Loads locales in nested subfolders, not just in the default directory
Rails.application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
