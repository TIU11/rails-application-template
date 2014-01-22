module PaginationHelper

  # Renders will_pagination information on the records within `span.pagination-record-count`
  def pagination_entries_info(model = nil)
    if model.respond_to? :total_pages
      content_tag :span, :class => "pagination-record-count" do
        page_entries_info model
      end
    end
  end

  # Renders will_paginate navigation links within `div.pagination`
  def pagination_nav(model = nil)
    if model.respond_to? :total_pages
      will_paginate model
    end
  end

end
