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

  CSS_CLASS_FOR_STATUS = {
    'active' => 'badge-primary',
    'inactive' => 'badge-secondary'
  }.freeze

  # Display model's status badge
  def status_tag(status, class: nil)
    # Read status when given an ApplicationRecord object
    status = status.status if status.is_a? ApplicationRecord

    span_class = CSS_CLASS_FOR_STATUS[status.to_s]
    tag.span status.titleize, class: "badge #{span_class} #{binding.local_variable_get(:class)}"
  end

  # +message+ optional message to override the default
  def no_records_message(records, message: nil)
    return if records.present?

    records = records.is_a?(ActiveRecord::Relation) ? records.klass.model_name.human.pluralize.downcase : 'records'
    message ||= "No #{records} found"
    tag.p message, class: 'lead'
  end

end
