# frozen_string_literal: true

# NOTE: when using custom types with Postgres arrays they must be registered (here) to work.
# When registered, they become a subtype of ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array
# which handles the array bits before invoking your custom type.
#
#     attribute :links, :link, array: true          # this works, becoming an array subtype
#     attribute :links, Type::Link.new, array: true # this acts like a non-array type
#
# Next, confirm the type with `MyModel.type_for_attribute(:links)`

ActiveRecord::Type.register(:localized_date, LocalizedDate)
ActiveRecord::Type.register(:string, Type::String, override: true)
ActiveRecord::Type.register(:token, Type::Token)

ActiveModel::Type.register(:localized_date, LocalizedDate)
ActiveModel::Type.register(:string, Type::String, override: true)
ActiveModel::Type.register(:token, Type::Token)
