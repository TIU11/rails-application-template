# frozen_string_literal: true

# Represents a user-entered code, like a coupon code, discount code or confirmation number.
# Avoids ambiguous characters that could cause user confusion or apprehension.
module Type
  class Token < ActiveRecord::Type::String

    AMBIGUITIES = [
      %w[B 8],
      %w[D O 0],
      %w[G 6],
      %w[I 1 l],
      %w[S 5],
      %w[Z 2]
    ].flatten.freeze
    CHARACTERS = ([*('A'..'Z'), *('0'..'9')] - AMBIGUITIES).freeze
    LENGTH = 6

    def initialize(precision: nil, limit: nil, scale: nil, length: LENGTH)
      @length = length
      super(precision: precision, limit: limit, scale: scale)
    end

    private

      def cast_value(value)
        if value == :random
          random_number
        elsif value.is_a? ::String
          value = value.upcase
          value if value.chars.all? { |c| c.in? CHARACTERS }
        end
      end

      def random_number
        Array.new(@length) { CHARACTERS.sample }.join
      end
  end
end
