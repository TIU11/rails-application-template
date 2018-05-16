# frozen_string_literal: true

# Exception Handler
require "custom_public_exceptions"
Rails.application.config.exceptions_app = CustomPublicExceptions.new Rails.public_path
