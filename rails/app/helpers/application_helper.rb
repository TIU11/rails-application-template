module ApplicationHelper

  # Render link to previous page, especially for cancelling on a form.
  # When previous page is this page or this isn't a GET request, then link to
  # stored session[:return_to].
  #
  # To set session[:return_to], you will usually add `store_location request.referer` to the edit action.
  def link_back(name, html_options = {})
    get_new_page = request.get? and (request.url != request.referer)
    url = get_new_page ? :back : session[:return_to]
    link_to name, url, html_options
  end

  # See Railscasts Pro #196
  # Works with `addNestedFields` Javascript function.
  def link_to_add_fields(name, f, association, class: nil)
    new_object = f.object.send(association).klass.new
    id = Time.new.to_i # any unique id
    css_class = 'add-nested-fields ' + binding.local_variable_get(:class)

    # Assumes your association has a '_fields' partial (e.g. 'user_fields.html.erb')
    partial = association.to_s.singularize + '_fields'

    fields_html = f.fields_for(association, new_object, child_index: id) do |builder|
      render(partial, f: builder)
    end

    link_to(name, '#0', class: css_class, data: {id: id, fields: fields_html.gsub("\n", "")})
  end
end
