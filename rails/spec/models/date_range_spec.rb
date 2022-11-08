# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateRange, type: :model do
  describe '#duration' do
    it 'calculates' do
      [
        { starts_on: Date.new(2020, 1, 1), ends_on: Date.new(2021, 1, 1), duration: 1.year + 1.day },
        { starts_on: Date.new(2020, 1, 1), ends_on: Date.new(2020, 12, 31), duration: 1.year },
        { starts_on: Date.new(2020, 1, 1), ends_on: Date.new(2020, 1, -1), duration: 1.month },
        { starts_on: Date.new(2020, 1, 1), ends_on: Date.new(2020, 2, 1), duration: 1.month + 1.day },
        { starts_on: Date.new(2020, 1, 1), ends_on: Date.new(2020, 1, 7), duration: 7.days }
      ].map { |h| h.values_at(:starts_on, :ends_on, :duration) }.each do |starts_on, ends_on, expected_duration|
        duration = DateRange.new(starts_on, ends_on).duration
        expect(duration).to be_a(ActiveSupport::Duration)
        expect(duration).to eq(expected_duration)
        expect(duration.inspect).to eq(expected_duration.inspect)
      end
    end
  end
end
