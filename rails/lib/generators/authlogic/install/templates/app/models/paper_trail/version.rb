# frozen_string_literal: true

module PaperTrail
  class Version < ApplicationRecord
    include PaperTrail::VersionConcern # what is this for?

    scope :sorted, -> { reorder(created_at: :desc) }
    scope :recent, -> { sorted.first(3) }

    #
    # Methods
    #

    # Get User when whodunnit is an id, otherwise return the raw string.
    # e.g.
    # => #<User: id: 1, email: 'ahoyt@tiu11.org'...>
    # => 'ahoyt: console'
    # => 'ahoyt: rake db:import:users'
    # => 'Anonymous'
    def who
      @who ||= begin
        user_id = whodunnit.to_i
        if user_id.positive?
          User.find_by(id: user_id) || user_id
        else
          whodunnit || 'Anonymous'
        end
      end
    end

    # Returns model's class object when available, +nil+ if a class was renamed or removed.
    def item_class
      @item_class ||= item_type.safe_constantize
    end

    # TODO: reject empty values? (or do we not save the empties in the first place)
    def enhanced_changeset
      if item_class.nil? # TODO: seems a lot like +else+ case. Combinable?
        result_changeset = object_changes
      elsif changeset.present?
        result_changeset = changeset.deep_dup
      else # changeset is empty on 'delete' event, so we'll create one
        result_changeset = {}
        object.each do |k, v|
          result_changeset[k] = [v, nil] if v.present?
        end
      end

      # replace any foreign_keys with the corresponding object
      # TODO: handle polymorphic
      ## When you handle poloymorphic, be aware of belongs_to parent on assignment
      belongs_to_associations.select { |a| a.foreign_key.in?(result_changeset.keys) && !a.polymorphic? }.each do |a|
        before_id, after_id = result_changeset[a.foreign_key]
        before_object = before_id && a.klass.find_by(id: before_id)
        after_object = after_id && a.klass.find_by(id: after_id)

        if before_object || after_object # don't replace keys that we couldn't look up
          result_changeset.delete(a.foreign_key) unless result_changeset.empty?
          result_changeset[a.name.to_s] = [before_object, after_object]
        end
      end

      result_changeset
    end

    # Consistent place to get the object attributes, since #object is nil on create.
    def object_attributes
      object || begin
        h = {}
        object_changes.each { |key, change| h[key] = change.last }
        return h
      end
    end

    # TODO: Determine if there should be a parent object instance when polymorphic. What is this returning?
    def object_instance
      @object_instance ||= begin
        if parent_association.present?
          parent_model
        else
          item_class&.find_by(id: item_id)
        end
      end
    end

    # based on notes from (http://coryforsyth.com/2013/06/02/programmatically-list-routespaths-from-inside-your-rails-app/)
    def route?
      routes.present?
    end

    def object_path
      route = routes.first # TODO: ignoring that we might have multiple routes to pick from
      params = { only_path: true }
               .merge(route.defaults) # ex. { controller: 'users', action: 'show' }
               .merge(object_instance.slice(*route.required_parts).symbolize_keys)
      ::Rails.application.routes.url_for(params)
    end

    # All :show routes on the object's controller
    def routes
      all_routes = ::Rails.application.routes.routes
      # TODO: consider object_instance.model_name.route_key
      controller_name = object_instance.class.name.underscore.pluralize

      all_routes.select do |route|
        route.defaults == { controller: controller_name, action: 'show' }
      end
    end

    private

      def belongs_to_associations
        @belongs_to_associations ||= item_class&.reflect_on_all_associations(:belongs_to) || []
      end

      # Assumes the polymorphic is a parent record and there is only one
      def parent_association
        @parent_association ||= begin
          belongs_to_associations.find do |a|
            a.polymorphic? && a.active_record.name.eql?(item_type) # TODO: why the name check?
          end
        end
      end

      def parent_model
        return unless parent_association.present?
        model_class = object_attributes["#{parent_association.name}_type"]&.safe_constantize
        foreign_key = "#{parent_association.name}_id"
        model_class.find_by(id: object_attributes[foreign_key]) if model_class && foreign_key
      end

  end
end
