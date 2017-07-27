module DatepickerHelper

  # Generate date input tag for use with 'bootstrap-datepicker-rails' gem
  # For available options, @see (http://bootstrap-datepicker.readthedocs.org/en/stable/options.html)
  #
  # Usage:
  #   datepicker_tag f, :start-date
  #   datepicker_tag f, :start-date, data: { date_start_date: Date.tomorrow.strftime("%Y-%m-%d") }
  #
  # TODO: datepicker doesn't activate when clicking the input-group-addon. Their docs out-of-date on this.
  def datepicker_tag(form, name, options = {})
    # Ensure date format consistent in text field and javascript configuration.
    # The defaults, as configured in Date::DATE_FORMATS[:default], might not match.
    value = form.object[name]
    if value.respond_to? :strftime
      value = value.strftime("%m-%d-%Y")
    end

    options = {
      value: value,
      data: {
        behavior: 'datepicker',
        date_format: 'yyyy-mm-dd',
        date_autoclose: true,
        date_today_highlight: true
      },
      autocomplete: 'off',
      class: 'form-control'
    }.deep_merge(options)

    content_tag :div, class: 'input-group date' do
      concat(form.text_field name, options)
      concat(content_tag :span, icon('calendar'), class: 'input-group-addon')
    end
  end

end
