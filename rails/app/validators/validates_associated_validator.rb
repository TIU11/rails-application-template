# frozen_string_literal: true

# Validates whether the associated object or objects are all valid. Merges all
# association validation messages onto the parent.
#
#   Class Post < ApplicationRecord
#     validates :comments, validate_associated: true
#   end
#
# This provides more detail than `validates_associated :tags`, which just provides
# a message "Tags is invalid."
#
# Derived from ActiveRecord::Validations::AssociatedValidator
class ValidatesAssociatedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    invalid_values = Array(value).reject { |r| valid_object?(r) }

    # Mimics ActiveModel::Errors.merge! but nests key within attribute name.
    invalid_values.each do |v|
      v.errors.each do |associated_error|
        record.errors.import(associated_error, attribute: [attribute, associated_error.attribute].join('.'))
      end
    end
  end

  private

    def valid_object?(record)
      (record.respond_to?(:marked_for_destruction?) && record.marked_for_destruction?) || record.valid?
    end
end
