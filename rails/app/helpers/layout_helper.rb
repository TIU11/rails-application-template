# frozen_string_literal: true

module LayoutHelper
  # Shorthand for a full-width container:
  # <div class="container">
  #   <div class="row">
  #     <div class="col-md-12">
  #       <!-- your content here -->
  #     </div>
  #   </div>
  # </div>
  # rubocop:disable Metrics/MethodLength
  def container_tag(class: nil, with_column: true, &block)
    klass = "container #{binding.local_variable_get(:class)}"
    content_tag :div, class: klass do
      content_tag :div, class: :row do
        if with_column
          content_tag :div, class: 'col-md-12' do
            capture(&block)
          end
        else
          capture(&block)
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  # Wraps container tag. Useful for applying a full-bleed background.
  # keyword arguments pass through
  def wrapped_container_tag(class: nil, with_column: true, &block)
    klass = "container-wrapper #{binding.local_variable_get(:class)}"
    content_tag :div, class: klass do
      container_tag(with_column: with_column, &block)
    end
  end
end
