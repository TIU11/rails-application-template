# frozen_string_literal: true

# Strips out empty spaces that are default on Ckeditor 5
module Type
  class EditorText < ActiveModel::Type::String

    EMPTY_P_TAG_REGEX = %r{\A(<p[^>]*>(\s|&nbsp;|</?\s?br\s?/?>)*</?p>)\1*\z}.freeze

    def serialize(value)
      super(value)
      apply_options(value)
    end

    private

      def cast_value(value)
        value = super(value)
        apply_options(value)
      end

      def apply_options(value)
        return if value.nil?

        remove_empty_p_tags(value)
      end

      def remove_empty_p_tags(value)
        value.match?(EMPTY_P_TAG_REGEX) ? nil : value
      end
  end
end
