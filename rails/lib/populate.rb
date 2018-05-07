# frozen_string_literal: true

# Helpers for populating the database with lots of data, without writing lots of code
#
# TODO
# * make recursive, allowing attribute hashes deeper than 2-layers
# * show/return hash of nested attribute changes, not just changes to the root object
# * test coverage
# * speedup bulk imports
#   @see (http://weblog.jamisbuck.org/2015/10/10/bulk-inserts-in-activerecord.html)
#
class Populate
  require 'colorize'

  class << self
    # Creates an object from the attributes provided, or updates an existing object.
    #
    # A :belongs_to association can be included by passing an attribute named after the
    # association and the value equivalent to the association's 'name' attribute.
    #
    # Options:
    # * cache_adds: cache new records so they can be referenced later. If they
    #   aren't referenced, will consume RAM without any performance benefit.
    #
    # Example:
    #   attrs = {email: 'jdoe@example.com', first_name: 'John', last_name: 'Doe'}
    #   Populate.update_or_create User, attrs, by: :email
    #   => Created User    1: John Doe
    #   => Unable to update User 'John Doe' because:
    #      {:email=>["is not an email"]}
    def update_or_create(klass, attributes, by: :name, verbose: false, cache_adds: false, cache: true)
      Cache.enable(cache)

      # make sure we have a class
      klass = klass.is_a?(Class) ? klass : klass.constantize

      # replace any association :name values with the object
      # TODO: make recursive, as this can only go 1-level deep
      attributes = populate_associations klass, attributes, by: :name

      begin
        object = klass.find_or_initialize_by attributes.slice(*by)
        action = object.new_record? ? 'create' : 'update'
        if object.update(attributes) && action == 'create' && cache_adds
          Cache.add(object)
        end
        changes = object.previous_changes
      rescue ActiveRecord::RecordNotSaved => e
        puts "#{self}.#{__callee__}: failed to assign attributes because:".red
        puts "\t#{object.errors.full_messages}".red
        raise e
      rescue RuntimeError => e
        puts "#{self}.#{__callee__}: failed to assign attributes because of #{e}".red
        puts "\t#{attributes}"
        raise e
      end

      show_changes = changes.any? && !object.new_record?

      if object.save
        object_string = verbose ? object.to_model : object.to_s # Readable output, if desired
        puts "#{action.titleize}d #{klass} #{object.id.to_s.rjust 4}: #{object_string}"
        puts "\tupdate: #{changes}" if show_changes
      end

      print_errors(klass, object, action)

      object
    end

    # Look in attributes for associations, look them up by name, and replace with the found object.
    # - Won't clobber any objects that are already in attributes, just strings
    # - Handles :belongs_to, :has_and_belongs_to_many
    # - Warns when lookup fails, and removes the non-existent value so the migration can proceed
    #
    # @return attributes {Hash} with found object instead of name {String}
    #
    # Example:
    #
    # User belongs_to Group
    # Populate.update_or_create User, {name: "John Doe", group: "Happy People"}
    # => associates John with the group named "Happy People"
    #
    # Populate.update_or_create User, {name: "John Doe", group: Groups.first}
    # => associates John with the first group
    def populate_associations(klass, attributes, by: :name)
      klass.reflect_on_all_associations.each do |reflection|
        # Drill down on :through associations
        reflection = reflection.delegate_reflection if reflection.is_a? ActiveRecord::Reflection::ThroughReflection

        next if reflection.polymorphic? # skip. Since we don't know which type will be referenced, we can't constantize

        association_name = reflection.name
        association_class = association_class(reflection)

        next if attributes[association_name].blank?
        puts "\t...populating #{klass}'s :#{association_name}"

        case reflection
        when ActiveRecord::Reflection::HasOneReflection
          populate_has_one_association association_name, association_class, attributes
        when ActiveRecord::Reflection::HasManyReflection
          populate_has_many_association association_name, association_class, attributes
        when ActiveRecord::Reflection::BelongsToReflection
          populate_belongs_to_association association_name, association_class, attributes
        when ActiveRecord::Reflection::HasAndBelongsToManyReflection
          populate_has_and_belongs_to_many_association association_name, association_class, attributes
        end
      end

      attributes
    end

    # ex. populate_associations(User, {county: 'Huntingdon - Mifflin - Juniata'})
    # ex. populate_associations(User, {phone: {number: '5551231234', extension: 1234}})
    def populate_has_one_association(name, association_klass, attributes)
      attributes[name] = find_by association_klass, attributes[name]
      # # recurse for nested associations
      # puts "association_klass: #{association_klass}, attributes[#{name}]: #{attributes[name]}"
      # attributes[name] = update_or_create(association_klass, attributes[name])
    end

    # ex. populate_associations(User, {county: 'Huntingdon - Mifflin - Juniata'})
    # ex. populate_associations(User, {county: {slug: 'huntingdon-mifflin-juniata'}})
    def populate_belongs_to_association(name, association_klass, attributes)
      attributes[name] = find_by association_klass, attributes[name]
    end

    def populate_has_many_association(name, association_klass, attributes)
      # puts "#{self}.#{__callee__}(#{name}, #{association_klass}, #{attributes}, by: :#{by})"
      return unless attributes[name].present?
      puts "\t'#{name}' should be an Array, but was #{attributes[name].class}" unless attributes[name].is_a? Array

      attributes[name] = attributes[name].collect do |attr|
        case attr
        when String, Hash
          object = find_by association_klass, attr
          next object
        else
          next attr
        end
      end.compact
    end

    def populate_has_and_belongs_to_many_association(name, association_klass, attributes)
      return unless attributes[name].present?
      puts "\t'#{name}' should be an Array, but was #{attributes[name].class}" unless attributes[name].is_a? Array

      attributes[name] = attributes[name].collect do |attr|
        case attr
        when String, Hash
          next find_by association_klass, attr
        else
          next attr
        end
      end.compact
    end

    # Lookup object by attributes or String.
    # For strings, attempts to find with the first attribute in this list:
    # * :name
    # * :title
    # * the FriendlyId slug column (e.g. :slug or :username)
    #
    # That means when you provide a :username 'ahoyt' but User has a :name attribute,
    # the find will fail because :name gets tried before the slug column.
    def find_by(klass, attributes)
      case attributes
      when String
        find_by_attributes(klass, guess_attribute_name(klass) => attributes)
      when Hash
        find_by_attributes(klass, attributes)
      end
    end

    def guess_attribute_name(klass)
      # consider friendly_id slug_column, if available
      slug_column = klass.try(:friendly_id_config)&.slug_column.to_s

      # try to guess an attribute name that will work
      guesses = ['name', 'title', *slug_column].reject(&:blank?)
      attribute_name = (guesses & klass.attribute_names).first

      if attribute_name.blank?
        raise "Cannot find association by String, as #{klass} doesn't have a guessable attribute: #{guesses}"
      end
      attribute_name
    end

    # Lookup object from the given attributes Hash
    # Uses Cache if enabled
    def find_by_attributes(klass, attributes)
      object = if Cache.enabled
                 Cache.find_by(klass, attributes)
               else
                 klass.find_by attributes
               end

      unless object
        puts "\tUnable to find #{klass} with #{attributes.inspect}".red
        Errors.log(klass, attributes)
      end

      object
    end

    private

    def print_errors(klass, object, action)
      return unless object.errors.any?
      puts <<~MESSAGE.strip.yellow
        Unable to #{action} #{klass} '#{object}' because:
        \tErrors: #{object.errors.messages}
        \tAttributes with errors: #{attributes_with_errors(object)}
        \tAttributes: #{object.attributes}
      MESSAGE
    end

    # return Hash of attribute values found in errors.keys, including nested attributes.
    def attributes_with_errors(model)
      attributes = {}
      model.errors.keys.each do |key|
        # use `reduce` to drill down to the (potentially nested) attribute values
        value = key.to_s.split('.').reduce(model) { |o, attribute| o.send(attribute) }
        attributes[key] = value
      end
      attributes
    end

    # Typically reflection.class_name, otherwise the :source option provides.
    # TODO handle options[:class_name]
    def association_class(reflection)
      class_name = reflection.options[:source] || reflection.class_name
      class_name.to_s.classify.constantize
    end
  end

  class Errors
    @errors = {}.with_indifferent_access

    class << self
      attr_reader :errors

      # count occurences of options (Hash) for klass
      def log(klass, options)
        @errors[klass.to_s] ||= {}
        @errors[klass.to_s][options.inspect] ||= 0
        @errors[klass.to_s][options.inspect] += 1
      end
    end
  end

  class Cache
    @cache = {}.with_indifferent_access
    @enabled = true

    class << self
      attr_reader :enabled

      def load(klass)
        @cache[klass.to_s] ||= klass.all
      end

      def add(object)
        load(object.class) << object
      end

      # Find first object that matches all parameters
      def find_by(klass, attributes)
        load(klass).find do |object|
          attributes.keys.all? { |key| object.send(key) == attributes[key] }
        end
      end

      def clear!(klass)
        @cache[klass.to_s] = nil
      end

      def enable(toggle = true)
        @enabled = toggle
      end
    end
  end

end
