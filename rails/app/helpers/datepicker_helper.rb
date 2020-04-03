# frozen_string_literal: true

module DatepickerHelper

  FORMAT_NAME = :default

  # Generate date input tag for use with 'bootstrap-datepicker-rails' gem
  # For available options, @see (http://bootstrap-datepicker.readthedocs.org/en/stable/options.html)
  #
  # Usage:
  #   datepicker_tag f, :start_date
  #   datepicker_tag f, :start_date, data: { date_start_date: Date.tomorrow }
  #
  # Ensures date format consistent in text field and javascript configuration.
  # However, you are responsible for converting the submitted date string to a Date object.
  # You can let the LocalizedDate type handle this for you:
  #     attribute :start_date, :localized_date
  #
  # TODO: datepicker doesn't activate when clicking the input-group-append. Their docs out-of-date on this.
  # rubocop:disable Metrics/MethodLength
  def datepicker_tag(form, name, options = {})
    value = form.object[name]&.to_date # cast value to a Date
    value = I18n.localize(value, format: FORMAT_NAME) if value.present?

    options = {
      value: value,
      data: {
        behavior: 'datepicker',
        date_format: datepicker_format(format: FORMAT_NAME),
        date_autoclose: true,
        date_today_highlight: true
      },
      autocomplete: 'off',
      class: 'form-control'
    }.deep_merge(options)

    format_date_values(options)

    content_tag :div, class: 'input-group mr-sm-2 date' do
      concat form.text_field(name, options)
      concat content_tag(:span,
                         content_tag(:span,
                                     icon('fas', 'calendar-alt'),
                                     class: 'input-group-text'),
                         class: 'input-group-append')
    end
    # rubocop:enable Metrics/MethodLength
  end

  # Maps each Ruby format to its corresponding Datepicker format
  # Structure: 'ruby' => 'datepicker'
  RUBY_TO_CHART_FORMAT_MAP = {
    '%m'  => 'mm',   # month of the year, zero-padded (01)
    '%-m' => 'm',    # month of the year, no-padded   (1)
    '%d'  => 'dd',   # day of the month, zero-padded  (01)
    '%-d' => 'd',    # day of the month, no-padded    (1)
    '%y'  => 'yy',   # year                           (17)
    '%Y'  => 'yyyy', # year with century              (2017)
    '%A'  => 'DD',   # full weekday name              (Monday)
    '%a'  => 'D',    # abbreviated weekday name       (Mon)
    '%b'  => 'M',    # abbreviated month name         (Jan)
    '%B'  => 'MM',   # full month name                (January)
  }.freeze

  # Get datepicker-expected format string for named format. Converts the corresponding I18n date format string.
  # If translation is missing, uses the constant Date::DATE_FORMATS.
  #
  # See specs for each format string:
  # * (http://bootstrap-datepicker.readthedocs.io/en/stable/options.html#format)
  # * (https://ruby-doc.org/core/Time.html#method-i-strftime)
  #
  # Note where the Ruby-land format strings are used:
  # * `I18n.l`    uses date.formats.default
  # * `Date.to_s` uses Date::DATE_FORMATS[:default]
  def datepicker_format(format: :default)
    ruby_format = I18n.translate("date.formats.#{format}",
                                 default: Date::DATE_FORMATS[format.to_sym]) # fallback to Date constants

    ruby_format.gsub(/%-?[mdyYaAbB]/, RUBY_TO_CHART_FORMAT_MAP)
  end

  # Format any date-like values using the given format,
  # making them match the formatted expected by datepicker JavaScript.
  def format_date_values(options)
    options[:data]&.each do |key, value|
      options[:data][key] = I18n.localize(value.to_date, format: FORMAT_NAME) if value.respond_to? :strftime
    end
  end

end
