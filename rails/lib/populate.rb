# module TIU
  # Helpers for populating the database with lots of data, without writing lots of code
  class Populate
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
    def self.update_or_create klass=nil, attributes={}, options={verbose: false, by: :name}
      # make sure we have a class
      klass = (klass.is_a? Class) ? klass : klass.constantize

      # replace any association :name values with the object
      attributes = populate_associations klass, attributes, by: :name

      object = klass.find_or_initialize_by attributes.slice(options[:by])
      object.attributes = attributes

      action = object.new_record? ? 'create' : 'update'
      changes = object.changes
      show_changes = changes.any? && !object.new_record?

      if object.save
        object_string = options[:verbose] ? object.to_model : object.to_s # Readable output, if desired
        puts "#{action.titleize}d #{klass} #{object.id.to_s.rjust 4}: #{object_string}"
        puts "\tupdate: #{changes}" if show_changes
      end

      if object.errors.any?
        puts "Unable to #{action} #{klass} '#{object}' because: \n\t#{object.errors.messages}"
        log_error User, object.errors.full_messages
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
    def self.populate_associations (klass, attributes, options={by: :name})
      # handle :belongs_to
      klass.reflect_on_all_associations(:belongs_to).each do |reflection|
        name = reflection.name
        association_klass = reflection.class_name.constantize

        # ex. populate_associations(User, {county: 'Huntingdon - Mifflin - Juniata'})
        if attributes[name].is_a? String
          attributes[name] = cached_find_by association_klass, name: attributes[name]
        end

        # ex. populate_associations(User, {county: {slug: 'huntingdon-mifflin-juniata'}})
        if attributes[name].is_a? Hash
          attributes[name] = cached_find_by association_klass, attributes[name]
        end
      end

      # handle :has_many
      klass.reflect_on_all_associations(:has_many).each do |reflection|
        name = reflection.name
        association_klass = reflection.class_name.constantize

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

      # handle :has_and_belongs_to_many
      klass.reflect_on_all_associations(:has_and_belongs_to_many).each do |reflection|
        name = reflection.name
        association_klass = reflection.class_name.constantize

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

      return attributes
    end

    # @usage find_by User, name: 'john'
    def self.find_by(klass, opt={})
      object = klass.send "find_by_#{ opt.keys.join('_and_') }", opt.values
      puts "\t#{klass} with #{opt.inspect} doesn't exist" unless object

      return object
    end

    def self.cached_find_by(klass, opt={})
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

  end
# end
