# frozen_string_literal: true

module ApplicationHelper

  # Render link to previous page, especially for cancelling on a form.
  # When previous page is this page or this isn't a GET request, then link to
  # stored session[:return_to].
  #
  # To set session[:return_to], simply setup the before_action:
  #
  #   `before_action :store_referrer, only: [:new, :edit]`
  #
  # or add `store_location request.referer` to the edit and new actions.
  def link_back(name, html_options = {})
    (get_new_page = request.get?) && (request.url != request.referer)
    url = get_new_page ? :back : session[:return_to]
    link_to name, url, html_options
  end

  # See Railscasts Pro #196
  # Works with `addNestedFields` Javascript function.
  def link_to_add_fields(name, f, association, class: nil)
    new_object = f.object.send(association).klass.new
    id = SecureRandom.hex # any unique id
    css_class = "add-nested-fields #{binding.local_variable_get(:class)}"

    # Assumes your association has a '_fields' partial (e.g. 'user_fields.html.erb')
    partial_name = association.to_s.singularize + '_fields'

    # If partial exists in current folder, use that else, try with the folder prefix assuming association matches folder
    # For shared partials, Partial Render method find_template looks for forward slash to lookup by path
    # @see (https://github.com/rails/rails/blob/master/actionview/lib/action_view/renderer/partial_renderer.rb) : 421
    if lookup_context.exists?(partial_name)
      partial = partial_name
    else
      prefix = association.to_s
      partial = prefix + '/' + partial_name
    end

    fields_html = f.fields_for(association, new_object, child_index: id) do |builder|
      render(partial, f: builder)
    end

    link_to(name, '#0', class: css_class, data: { id: id, fields: fields_html.delete("\n") })
  end

  CSS_CLASS_FOR_STATUS = {
    'active' => 'badge-primary',
    'inactive' => 'badge-secondary'
  }.freeze

  # Display model's status badge
  def status_tag(status, class: nil)
    # Read status when given an ApplicationRecord object
    status = status.status if status.is_a? ApplicationRecord

    span_class = CSS_CLASS_FOR_STATUS[status.to_s]
    content_tag :span, status.titleize, class: "badge #{span_class} #{binding.local_variable_get(:class)}"
  end

  # +message+ optional message to override the default
  def no_records_message(records, message: nil)
    return if records.present?

    records = records.is_a?(ActiveRecord::Relation) ? records.klass.model_name.human.pluralize.downcase : 'records'
    message ||= "No #{records} found"
    content_tag :p, message, class: 'lead'
  end

end
