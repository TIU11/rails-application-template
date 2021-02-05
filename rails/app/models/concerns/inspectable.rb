# Inspectable methods. Provides a clean `inspect` for ActiveModel::Model models.
#
# Example:
#     class Car
#       include ActiveModel::Model
#       include ActiveModel::Attributes
#       include Inspectable
#     end
module Inspectable
  def inspect
    inspection = attributes.map do |name, value|
      "#{name}: #{value.inspect}"
    end.join(', ')
    "#<#{self.class}:#{object_id} #{inspection}>"
  end
end
