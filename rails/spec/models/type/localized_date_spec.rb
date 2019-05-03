# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocalizedDate, type: :model do

  # Define a test model. Subclass of self to namespace within this test.
  class self::MockModel < ApplicationRecord
    attribute :starts_on, :localized_date
  end

  before(:all) { create_table }

  after(:all) { drop_table }

  it "accepts dates" do
    date = Date.new(2018, 1, 22)
    model = self.class::MockModel.new(starts_on: date)
    expect(model.starts_on).to be_a(::Date)
    expect(model.starts_on).to eq(date)
    model.save
    model.reload
    expect(model.starts_on).to eq(date)
  end

  it "accepts localized date strings" do
    valid_dates = [['1/22/2018', Date.new(2018, 1, 22)]]
    valid_dates.each do |string, expected_date|
      model = self.class::MockModel.new(starts_on: string)
      expect(model.starts_on).to be_a(::Date)
      expect(model.starts_on).to eq(expected_date)
      model.save
      model.reload
      expect(model.starts_on).to eq(expected_date)
    end
  end

  it "handles format strings with flags and width" do
    unsafe_formats = ['%-m/%-d/%Y', '%_m/%0d/%2Y']
    date_string = '1/22/2018'
    expected_date = Date.new(2018, 1, 22)
    unsafe_formats.each do |format_string|
      type = LocalizedDate.new format: format_string
      expect(type.cast(date_string)).to eq(expected_date)
    end
  end

  def create_table
    ActiveRecord::Base.connection.create_table :mock_models do |t|
      t.date :starts_on
      t.timestamps
    end
  end

  def drop_table
    ActiveRecord::Base.connection.drop_table :mock_models
  end

end
