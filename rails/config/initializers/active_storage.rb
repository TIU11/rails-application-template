# frozen_string_literal: true

# Active Storage configuration
# TODO: remove once all servers support the defaults, likely with Ubuntu 22.04 LTS.
Rails.application.configure do
  # Modify default ActiveStorage.variable_content_types to match our servers' capabilities.
  config.active_storage.variable_content_types = [
    "image/png",
    "image/gif",
    "image/jpg",
    "image/jpeg",
    "image/pjpeg",
    "image/tiff",
    "image/bmp",
    "image/vnd.adobe.photoshop",
    "image/vnd.microsoft.icon",
    "image/webp"
    # "image/avif", # NOTE: unsupported with libvips on Ubuntu 20.04 LTS
    # "image/heic", # NOTE: unsupported with libvips on Ubuntu 20.04 LTS
    # "image/heif"  # NOTE: unsupported with libvips on Ubuntu 20.04 LTS
  ]
end
