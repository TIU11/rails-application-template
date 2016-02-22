# Helpers for populating the database with lots of data, without writing lots of code
#
# TODO
# * make recursive, allowing attribute hashes deeper than 2-layers
# * show/return hash of nested attribute changes, not just changes to the root object
# * test coverage
# * speedup bulk imports
#   @see (http://weblog.jamisbuck.org/2015/10/10/bulk-inserts-in-activerecord.html)

# module TIU
  class Populate
    require 'colorize'

    @@cache = {}.with_indifferent_access
    @@errors = {}.with_indifferent_access

    # Creates an object from the attributes provided, or updates an existing object.
    #
    # A :belongs_to association can be included by passing an attribute named after the
    # association and the value equivalent to the association's 'name' attribute.
    #
    # Example:
    #   attrs = {email: 'jdoe@example.com', first_name: 'John', last_name: 'Doe'}
    #   Populate.update_or_create User, attrs, by: :email
    #   => Created User    1: John Doe
    #   => Unable to update User 'John Doe' because:
    #      {:email=>["is not an email"]}
    def self.update_or_create(klass, attributes, by: :name, verbose: false)
      # make sure we have a class
      klass = (klass.is_a? Class) ? klass : klass.constantize

      # replace any association :name values with the object
      # TODO: make recursive, as this can only go 1-level deep
      attributes = populate_associations klass, attributes, by: :name

      begin
        object = klass.find_or_initialize_by attributes.slice(*by)
        action = object.new_record? ? 'create' : 'update'
        object.update attributes
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

      if object.errors.any?
        puts "Unable to #{action} #{klass} '#{object}' because:".yellow
        puts "\tErrors: #{object.errors.messages}".yellow
        puts "\tAttributes with errors: #{attributes_with_errors(object)}".yellow
        puts "\tAttributes: #{object.attributes}"
        log_error klass, object.errors.full_messages
      end

      return object
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
    def self.populate_associations(klass, attributes, by: :name)
      associations_found = [] # debug: keep track of associations
      klass.reflect_on_all_associations.each do |reflection|
        # Drill down on :through associations
        reflection = reflection.delegate_reflection if reflection.is_a? ActiveRecord::Reflection::ThroughReflection

        next if reflection.polymorphic? # skip. Since we don't know which type will be referenced, we can't constantize

        name = reflection.name

        association_klass = (
          # Typically reflection.class_name, otherwise the :source option provides.
          # TODO handle options[:class_name]
          reflection.options[:source] || reflection.class_name
        ).to_s.classify.constantize

        next if attributes[name].blank?
        associations_found << name
        puts "\t...populating #{klass}'s :#{name}"

        case reflection
        when ActiveRecord::Reflection::HasOneReflection
          populate_has_one_association name, association_klass, attributes, by: by
        when ActiveRecord::Reflection::HasManyReflection
          populate_has_many_association name, association_klass, attributes, by: by
        when ActiveRecord::Reflection::BelongsToReflection
          populate_belongs_to_association name, association_klass, attributes, by: by
        when ActiveRecord::Reflection::HasAndBelongsToManyReflection
          populate_has_and_belongs_to_many_association name, association_klass, attributes, by: by
        end
      end

      # Debugging info
      # puts "#{self}: attributes for #{klass} associations, #{associations_found}:\n#{attributes.slice(*associations_found)}".cyan

      return attributes
    end

    def self.populate_has_one_association(name, association_klass, attributes, by: :name)
      # ex. populate_associations(User, {county: 'Huntingdon - Mifflin - Juniata'})
      if attributes[name].is_a? String
        attributes[name] = cached_find_by association_klass, name: attributes[name]
      end

      # ex. populate_associations(User, {phone: {number: '5551231234', extension: 1234}})
      if attributes[name].is_a? Hash
        attributes[name] = cached_find_by association_klass, attributes[name]

        # # recurse for nested associations
        # puts "association_klass: #{association_klass}, attributes[#{name}]: #{attributes[name]}"
        # attributes[name] = update_or_create(association_klass, attributes[name])
      end
    end

    def self.populate_belongs_to_association(name, association_klass, attributes, by: :name)
      # ex. populate_associations(User, {county: 'Huntingdon - Mifflin - Juniata'})
      if attributes[name].is_a? String
        attributes[name] = cached_find_by association_klass, name: attributes[name]
      end

      # ex. populate_associations(User, {county: {slug: 'huntingdon-mifflin-juniata'}})
      if attributes[name].is_a? Hash
        attributes[name] = cached_find_by association_klass, attributes[name]
      end
    end

    def self.populate_has_many_association(name, association_klass, attributes, by: :name)
      # puts "#{self}.#{__callee__}(#{name}, #{association_klass}, #{attributes}, by: :#{by})"
      if attributes[name].is_a? Array
        attributes[name] = attributes[name].collect { |attr|
          if attr.is_a? String
            next cached_find_by association_klass, name: attr
          elsif attr.is_a? Hash
            object = cached_find_by association_klass, attr
            puts "#{self}.#{__callee__}: unable to find :#{name} by Hash #{attr}".red unless object
            next object
          else
            next attr
          end
        }.compact
      elsif attributes[name].present?
        puts "\tExpected '#{name}' to be an Array, but found a #{attributes[name].class}"
      end
    end

    def self.populate_has_and_belongs_to_many_association(name, association_klass, attributes, by: :name)
      if attributes[name].is_a? Array
        attributes[name] = attributes[name].collect { |attr|
          if attr.is_a? String
            next cached_find_by association_klass, name: attr
          elsif attr.is_a? Hash
            next cached_find_by association_klass, attr
          else
            next attr
          end
        }.compact
      elsif attributes[name].present?
        puts "\tExpected '#{name}' to be an Array, but found a #{attributes[name].class}"
      end
    end

    # @usage find_by User, name: 'john'
    def self.find_by(klass, opt = {})
      object = klass.find_by opt
      puts "\t#{klass} with #{opt.inspect} doesn't exist" unless object

      return object
    end

    def self.cached_find_by(klass, opt = {})
      # load objects from cache
      objects = @@cache[klass.to_s] || (@@cache[klass.to_s] = klass.all)

      # find object that matches all parameters
      object = objects.find {|o|
        opt.keys.all? {|k|
          o.send(k) == opt[k]
        }
      }
      unless object
        puts "\t#{klass} with #{opt.inspect} doesn't exist"
        log_error(klass, opt)
      end

      return object
    end

    def self.errors
      @@errors
    end

    private

    def self.log_error(klass, opt)
      @@errors[klass.to_s] ||= {}
      @@errors[klass.to_s][opt.inspect] ||= 0
      @@errors[klass.to_s][opt.inspect] += 1
    end

    # return Hash of attribute values found in errors.keys, including nested attributes.
    def self.attributes_with_errors(model)
      attributes = {}
      model.errors.keys.each do |key|
        # use `reduce` to drill down to the (potentially nested) attribute values
        value = key.to_s.split('.').reduce(model){|o, attribute| o.send(attribute)}
        attributes[key] = value
      end
      return attributes
    end

  end
# end
