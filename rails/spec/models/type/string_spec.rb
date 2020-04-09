# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Type::String, type: :model do

  # Define a test model. Subclass of self to namespace within this test.
  class self::ModelForType
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :bug, Type::String.new(squish: true)
    attribute :paint, Type::String.new(strip: true)
    attribute :look, Type::String.new(nilify_blank: true)
  end

  it "squishes a bug" do
    model = self.class::ModelForType.new bug: ' a     squished   string  '
    expect(model.bug).to eq('a squished string')
  end

  it "strips paint" do
    model = self.class::ModelForType.new paint: ' a     stripped   string  '
    expect(model.paint).to eq('a     stripped   string')
  end

  it "nillifies a blank look" do
    model = self.class::ModelForType.new look: ' '
    expect(model.look).to be_nil
  end

end
