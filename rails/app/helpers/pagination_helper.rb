# frozen_string_literal: true

module PaginationHelper

  # Renders will_pagination information on the records within `span.pagination-record-count`
  def pagination_entries_info(model = nil)
    return unless model.respond_to? :total_pages
    content_tag :span, class: 'pagination-record-count' do
      page_entries_info model
    end
  end

  # Renders will_paginate navigation links within `div.pagination`
  def pagination_nav(model = nil, options: {})
    will_paginate(model, params: options) if model.respond_to? :total_pages
  end

end
