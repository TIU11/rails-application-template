# We focus on two types of tests:
# 1. System Tests
#   * tests user interaction with the whole system, so a few tests covers a lot
#   * slow to run, but we only use a few tests, carefully targeting broad tests of functionality
#   * replace 'feature' tests, which don't share a process with Rails (they require database_cleaner)
# 2. Unit Tests
#   * detailed test methods on models, services, etc.
#   * we don't aim for 100% coverage, but target high-risk (e.g. complex) and high-value code
#
# Further reading:
# https://medium.com/table-xi/a-quick-guide-to-rails-system-tests-in-rspec-b6e9e8a8b5f6
# https://chriskottom.com/blog/2017/04/full-stack-testing-with-rails-system-tests/
# https://robots.thoughtbot.com/headless-feature-specs-with-chrome
# https://github.com/thoughtbot/capybara-webkit

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end
end
