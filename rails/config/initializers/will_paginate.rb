# frozen_string_literal: true

# Allow pagination of static arrays (but still just try to use ActiveRecord::Relation)
# See https://github.com/mislav/will_paginate/blob/master/lib/will_paginate/array.rb

require 'will_paginate/array'

# This extension code was written by Isaac Bowen, originally found
# at (http://isaacbowen.com/blog/using-will_paginate-action_view-and-bootstrap/)
# now see (https://gist.github.com/henrik/1214011)

require 'will_paginate/view_helpers/action_view'

module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {})
      if collection.is_a? Hash
        options = collection
        collection = nil
      end
      # Taken from original will_paginate code to handle if the helper is not passed a collection object.
      collection ||= infer_collection_from_controller
      options[:renderer] ||= BootstrapLinkRenderer
      super.try :html_safe
    end

    class BootstrapLinkRenderer < LinkRenderer
      protected

        def html_container(html)
          tag.ul html, container_attributes
        end

        def page_number(page)
          tag.li link(page, page, rel: rel_value(page)), class: ('active' if page == current_page)
        end

        def gap
          tag.li link('&hellip;'.html_safe, '#'), class: 'disabled'
        end

        def previous_or_next_page(page, text, classname)
          tag.li link(text, page || '#'),
                 class: [
                   (classname[0..3] if @options[:page_links]),
                   (classname if @options[:page_links]),
                   ('disabled' unless page)
                 ].join(' ')
        end
    end
  end
end
