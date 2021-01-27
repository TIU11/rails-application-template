# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  #
  # Class Methods
  #

  class << self

    # Returns a random record, or +n+ random records, from the collection.
    # If the collection is empty, the first form returns +nil+, and the second
    # form returns an empty array.
    #
    #   User.sample # => #<User id: 4, name: "George P. Burdell">
    #
    #   User.sample(2)
    #   # => [
    #   #      <#User id:7, name: "Anson Hoyt">,
    #   #      <#User id:3, name: "Colby Guyer">
    #   #    ]
    #
    # TODO: slows down for large tables (takes ~1 second for ~500k records)
    # - For Postgres 9.5+, consider TABLESAMPLE.
    # - https://www.2ndquadrant.com/en/blog/tablesample-and-other-methods-for-getting-random-tuples/
    def sample(sample_size = nil)
      case ActiveRecord::Base.connection.adapter_name
      when 'PostgreSQL', 'SQLite'
        order(Arel.sql('RANDOM()')).first(sample_size)
      when 'MySQL'
        order(Arel.sql('RAND()')).first(sample_size)
      when 'SQLServer'
        order(Arel.sql('NEWID()')).first(sample_size)
      else
        # Here are more http://stackoverflow.com/questions/19412/how-to-request-a-random-row-in-sql
        raise 'Current database adapter is not supported.'
      end
    end

    # Returns Array of duplicate records, based on the match_attributes.
    # The first record for the match_attributes isn't returned. Any additional
    # ones encountered are considered to be duplicates (and are returned).
    #
    # Apply an order if you care about which of the matching objects is considered the keeper vs. a duplicate.
    #
    #   User.order(created_at: :asc).duplicates  # newest objects are considered duplicates
    #   User.order(created_at: :desc).duplicates # oldest objects are considered duplicates
    #
    # TODO: when no matched_attributes are provided, returns all but first object.
    # That might not be what you're thinking of as "duplicates".
    def duplicates(matched_attributes: foreign_keys)
      all # start with the current ActiveRecord::Relation
        .group_by { |o| o.attributes.slice(*matched_attributes.map(&:to_s)).values }
        .flat_map { |_, matches| matches.drop(1) } # drops first. the rest are duplicates
    end

    # Returns all foreign_keys for this model
    def foreign_keys
      reflect_on_all_associations(:belongs_to).map(&:foreign_key)
    end

  end

  #
  # Instance Methods
  #

  # Run all validators defined on the attribute. Returns +true+ if no errors otherwise +false+.
  # @see (http://stackoverflow.com/questions/4804591/rails-activerecord-validate-single-attribute)
  def attribute_valid?(attribute_name)
    self.class.validators_on(attribute_name).each do |validator|
      validator.validate_each(self, attribute_name, self[attribute_name])
    end

    errors[attribute_name].blank?
  end

  # Run all validators defined on the attribute. Raises ActiveRecord::RecordInvalid if there are any errors.
  def validate_attribute!(attribute_name)
    raise ActiveRecord::RecordInvalid, self unless attribute_valid?(attribute_name)
  end

end
