class PaperTrail::Version < ApplicationRecord
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
      if user_id > 0
        User.find_by(id: user_id) || user_id
      else
        whodunnit || 'Anonymous'
      end
    end
  end

  def item_class
    @item_class ||= item_type.safe_constantize
  end

  # TODO: reject empty values? (or do we not save the empties in the first place)
  def enhanced_changeset
    if changeset.present?
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
    return result_changeset
  end

  # Consistent place to get the object attributes, since #object is nil on create.
  def object_attributes
    object || begin
      h = {}
      object_changes.each{|key, change| h[key] = change.last}
      return h
    end
  end

  def object_instance
    @object_instance ||= begin
      model_class, foreign_key = determine_model_from_polymorphic
      if model_class && foreign_key
        model_class.find_by(id: object_attributes[foreign_key])
      else
        item_class.find_by(id: item_id)
      end
    end
  end

  # based on notes from (http://coryforsyth.com/2013/06/02/programmatically-list-routespaths-from-inside-your-rails-app/)
  def has_route?
    routes.present?
  end

  def object_path
    route = routes.first # TODO: ignoring that we might have multiple routes to pick from
    params =  { only_path: true }
              .merge(route.defaults) # ex. {:controller=>"users", :action=>"show"}
              .merge(object_instance.slice(*route.required_parts).symbolize_keys)
    Rails.application.routes.url_for(params)
  end

  # All :show routes on the object's controller
  def routes
    all_routes = Rails.application.routes.routes
    controller_name = object_instance.class.name.underscore.pluralize
    all_routes.select{ |route|
      route.defaults == {controller: controller_name, action: 'show'}
    }
  end

  private

    def belongs_to_associations
      @belongs_to_associations ||= item_class.reflect_on_all_associations(:belongs_to)
    end

    def determine_model_from_polymorphic
      polymorphic_association = belongs_to_associations.find { |a|
        a.polymorphic? && a.active_record.name.eql?(item_type)
      }
      if polymorphic_association.present?
        model_class = object_attributes[polymorphic_association.name.to_s + "_type"].safe_constantize
        model_foreign_id_name = polymorphic_association.name.to_s + "_id"
      end
      return [model_class, model_foreign_id_name]
    end

end
