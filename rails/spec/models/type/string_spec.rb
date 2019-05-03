# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Type::String, type: :model do
  # TODO: determine why ActiveModel lookup of the override type :string is not working
  # ActiveModel::Type.lookup(:string) # => ActiveModel::Type::String
  # ActiveRecord::Type.lookup(:string) # => Type::String
  # This works on ActiveRecord, using Position as test
  # strip needs tested yet
  it "squished a name" do
    model = Position.new(title: ' a     squished   string  ')
    expect(model.title).to eq('a squished string')
  end

end
