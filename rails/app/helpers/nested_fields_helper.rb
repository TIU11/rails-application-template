# ==Reference
#
# * http://railscasts.com/episodes/196-nested-model-form-revised
# * https://github.com/ryanb/nested_form
# * https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for
# * https://guides.rubyonrails.org/v4.1.9/form_helpers.html
#
# ==Example
#
#   # organizations/_form.html.erb
#   form_for @organization do |form|
#     form.fields_for :users do |user|
#       render 'user_fields', form: user
#     end
#   link_to_add_fields icon('fas', :plus, 'Add'), form, :users, class: 'float-right'
#   end
#
#   # users/_user_fields.html.erb
#   tag.tag class: 'nested-fields user-fields' do
#     form.text_field :name, class: 'form-control'
#     form.hidden_field :_destroy
#     link_to_remove_fields
#   end
module NestedFieldsHelper
  # Works with `addNestedFields` JavaScript function.
  def link_to_add_fields(name, form, association, options = {})
    new_object = form.object.send(association).klass.new
    id = SecureRandom.hex # any unique id

    fields_html = form.fields_for(association, new_object, child_index: id) do |builder|
      render(partial_for(association), form: builder)
    end

    # link options
    default_options = { data: { id: id, fields: fields_html.delete("\n") } }
    options = default_options.deep_merge(options)
    options[:class] = Array(options[:class]) << 'add-nested-fields'

    link_to(name, '#', options)
  end

  # Works with `removeNestedFields` JavaScript function.
  def link_to_remove_fields(name = icon('fas', :times), options = {})
    options[:class] = Array(options[:class]) << 'remove-nested-fields'

    link_to(name, '#', options)
  end

  private

    def partial_for(association)
      # Assumes your association has a '_fields' partial (e.g. 'user_fields.html.erb')
      partial_name = association.to_s.singularize + '_fields'

      # Find matching partial. Also checks the relevant +views/association+ folder.
      prefixes = lookup_context.prefixes + [association.to_s]
      template = lookup_context.find(partial_name, prefixes, true)

      template.virtual_path.sub(%r{/_}, '/') # return path to be used with +render+.
    end
end
