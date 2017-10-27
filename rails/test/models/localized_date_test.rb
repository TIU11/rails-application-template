require 'test_helper'

class LocalizedDateTest < ActiveSupport::TestCase
  test "casting bad date returns nil" do
    type = LocalizedDate.new

    ['foo', '2017/1/1', '30/1/2017', '1-30-2017'].each do |bad_value|
      date = type.cast(bad_value)
      assert_nil date
    end
  end

  test "casting localized string or date-like object returns date" do
    type = LocalizedDate.new

    ['1/30/2017', Date.today, Time.current, Time.now].each do |value|
      date = type.cast(value)
      assert_instance_of Date, date
    end
  end
end
