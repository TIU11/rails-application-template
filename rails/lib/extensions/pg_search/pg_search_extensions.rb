module PgSearchExtensions

  # Returns path when searchable has a :show page.
  def searchable_path
    resource_path(searchable)
  end

  # Return resources the searchable :belongs_to
  def parent_resources(with_path: true)
    resources = []
    searchable.class.reflect_on_all_associations(:belongs_to).each do |reflection|
      resource = searchable.public_send(reflection.name)
      resources << resource if !with_path || resource_path(resource)
    end

    resources
  end

  # All :show routes for the resource
  def routes(resource = searchable)
    route_key = resource.model_name.route_key

    ::Rails.application.routes.routes.select do |route|
      route.defaults == { controller: route_key, action: 'show' }
    end
  end

  def resource_path(resource)
    route = routes(resource).first # TODO: ignoring that we might have multiple routes to pick from
    return unless route

    params = { only_path: true }
             .merge(route.defaults) # ex. { controller: 'users', action: 'show' }
             .merge(resource.slice(*route.required_parts).symbolize_keys)
    ::Rails.application.routes.url_for(params)
  end
end
