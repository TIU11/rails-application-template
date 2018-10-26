# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Type::Token, type: :model do

  # Define a test model. Subclass of self to namespace within this test.
  class self::ModelForType
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :token, :token, default: :random
  end

  it "allows a :random default value" do
    model = self.class::ModelForType.new
    expect(model.token).to be_a(::String)
    expect(model.token.length).to eq(::Type::Token::LENGTH)
  end

  it "allows valid tokens" do
    valid_tokens = %w[A A3]
    valid_tokens.each do |token|
      model = self.class::ModelForType.new(token: token)
      expect(model.token).to be_a(::String)
      expect(model.token).to eq(token)
    end
  end

end
