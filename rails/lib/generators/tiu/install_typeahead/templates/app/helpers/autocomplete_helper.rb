# Pair of helpers for rendering a Twitter Typeahead. You must provide the container with `tt-options`.
# As long as they're within this container, you're free to add any structural and display markup.
#
# Usage:
# <div class="autocomplete-list" data-tt-options="<%= { input_name: "foo[bar_ids][]"}.to_json %>">
#   <%= autocomplete_tag :bar_id, 'bar-typeahead', placeholder: 'Search by Name' %>
#   <%= autocomplete_selections items: @foo.bars, field_name: "foo[bar_ids][]" %>
# </div>
module AutocompleteHelper
  def autocomplete_tag(field, name, options = {})
    capture do
      concat text_field_tag( field, nil,
                             class: "#{name} form-control #{options[:class]}",
                             placeholder: options[:placeholder],
                             autocomplete: 'off')
      concat content_tag :span,
                         icon('refresh', nil, class: 'fa-spin'),
                         class: 'form-control-feedback hidden',
                         'aria-hidden' => "true"
    end
  end

  # For search forms, you may want `include_hidden: false`
  #
  # `concat` and `capture` explained by (http://thepugautomatic.com/2013/06/helpers/)
  # with internals explained by (http://yehudakatz.com/2009/08/31/simplifying-rails-block-helpers-with-a-side-of-rubinius/)
  def autocomplete_selections(items:, field_name:, include_hidden: true, display_field: 'name')
    capture do
      # When there are no `items` checkboxes checked, this empty value will still be submitted.
      # Without this, deleting all items will submit no changes, which isn't what we want on edit forms.
      concat hidden_field_tag field_name, [] if include_hidden

      concat(
        capture do
          content_tag :ul, class: 'autocomplete-selections' do
            items.each do |item|
              concat(
                capture do
                  content_tag :li, class: 'item' do
                    concat content_tag(:span, item.send(display_field), class: 'item-text')
                    concat content_tag(:i, nil, class: 'pull-right fa fa-times', title: 'Click to remove')
                    concat tag(:input, type: "hidden", name: field_name, value: item.id)
                  end
                end
              )
            end
          end
        end
      )
    end
  end

end
