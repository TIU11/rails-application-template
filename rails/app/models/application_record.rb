class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  #
  # Class Methods
  #

  class << self

    # Select one or more random records from the database
    # Ex. "The winners are #{User.sample(3).to_sentence}!"
    def sample(sample_size = 1)
      case ActiveRecord::Base.connection.adapter_name
      when 'PostgreSQL', 'SQLite'
        limit(sample_size).order('RANDOM()')
      when 'MySQL'
        limit(sample_size).order('RAND()')
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
    def duplicates(matched_attributes: foreign_keys)
      all # start with the current ActiveRecord::Relation
        .group_by { |o|
          o.attributes.slice(*matched_attributes.map(&:to_s)).values
        }
        .flat_map { |_key, matches|
          matches.shift # drop first object
          matches # return all remaining objects. these are the duplicates
        }
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
    raise ActiveRecord::RecordInvalid.new(self) unless attribute_valid?(attribute_name)
  end

end
