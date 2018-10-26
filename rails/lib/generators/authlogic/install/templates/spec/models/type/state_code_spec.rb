# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Type::StateCode, type: :model do

  # Define a test model. Subclass of self to namespace within this test.
  class self::ModelForType
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :code, :state_code
  end

  it "allows valid state codes" do
    valid_state_codes = [:pa, ' pa', 'pennsylvania  ', "\tPENNSYLVANIA \n\t\r"]
    valid_state_codes.each do |code|
      model = self.class::ModelForType.new(code: code)
      expect(model.code).to be_a(::String)
      expect(model.code).to eq('PA')
    end
  end

end
