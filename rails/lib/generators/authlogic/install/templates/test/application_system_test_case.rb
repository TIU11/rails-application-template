require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Note, for debugging it is helpful to see the browser with:
  # driven_by :selenium, using: :chrome, screen_size: [1200, 1200]
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
