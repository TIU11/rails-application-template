module DatepickerHelper

  # Generate date input tag for use with 'bootstrap-datepicker-rails' gem
  #
  #   datepicker_tag f, :start-date %>
  def datepicker_tag(form, name, options = {})
    options.reverse_merge!({
      data: {behavior: 'datepicker', 'date-format' => 'm-d-yyyy'},
      autocomplete: 'off',
      class: 'form-control'
    })

    content_tag :div, class: 'input-group' do
      concat(form.text_field name, options)
      concat(content_tag :span, icon('calendar'), class: 'input-group-addon')
    end
  end

end
