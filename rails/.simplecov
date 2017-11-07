# SimpleCov configuration used across entire test suite.
#
# * Add `require 'simplecov'` to test/test_helper.rb and spec/rails_helper.rb
# * Run entire test suite, `rails spec test test:system`
#   (report only shows coverage for the tests than ran)
# * View report, `open ./coverage/index.html`

SimpleCov.start 'rails' do
  add_filter '/lib/generators/'
  add_filter '/lib/templates/'
end
