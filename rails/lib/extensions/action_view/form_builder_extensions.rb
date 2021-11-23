module Extensions
  module ActionView
    module FormBuilderExtensions
      # Extracts the group from each element in the collection
      #
      #   @users where User belongs_to :organization
      #
      # Alternative to grouped_collection_select, which requires a nested collection:
      #
      #   @organizations where Organization has_many :users
      #
      # Taken from https://makandracards.com/makandra/33755-a-non-weird-replacement-for-grouped_collection_select
      # without [collect_hash](https://makandracards.com/makandra/735-collect-a-hash-from-an-array)
      def flat_grouped_collection_select(field, collection, group_label_method, value_method, label_method, options = {}, html_options = {})
        hash = collection.group_by(&group_label_method).map do |group_label, group_entries|
          list_of_pairs = group_entries.collect do |entry|
            [entry.send(label_method), entry.send(value_method).to_s]
          end
          [group_label, list_of_pairs]
        end.to_h
        options_options = {} # options.slice(:prompt, :divider) are duplicative and ignored, respectively. So, passing nothing down.
        selected_key = object.send(field).to_s
        select(field, @template.grouped_options_for_select(hash, selected_key, options_options), options, html_options)
      end

      # Generate date input tag for use with 'flatpickr' npm package.
      # For available options, @see (https://flatpickr.js.org/options/)
      #
      # Usage:
      #   form.flatpickr_field :starts_on, placeholder: 'Start date'
      #   form.flatpickr_field :starts_on, data: { min_date: Date.tomorrow }
      #
      # Ensures date format consistent in text field and javascript configuration.
      # However, you are responsible for converting the submitted date string to a Date object.
      #
      # 1. You can let the LocalizedDate type handle this for you:
      #
      #     attribute :starts_on, :localized_date
      #
      # 2. You can define virtual attributes methods: (e.g. for Time which has no type)
      #
      #     attribute :starts_at, :datetime
      #
      #     def starts_at_string
      #       I18n.l starts_at, format: :default
      #     rescue ArgumentError
      #       nil
      #     end
      #
      #     def starts_at_string=(value)
      #       safe_format_str = "%m/%d/%Y %I:%M%P" # TODO: extract I18n.translate("time.formats.input").gsub
      #       self.starts_at = Time.zone.strptime(value, safe_format_str) if value.present?
      #     end
      def flatpickr_field(method, options = {})
        value = if options.key?(:value)
                  options[:value]
                else
                  object.send(method)
                end

        input_options = { value: value,
                          autocomplete: 'off',
                          placeholder: options.delete(:placeholder),
                          data: { input: true },
                          class: 'form-control' }

        container_options = {
          class: ['input-group mr-sm-2 date'] + Array(options.delete(:class)),
          id: "#{object_name}_#{method}_input_group",
          data: { provide: 'flatpickr',
                  date_format: flatpickr_format(format: :default),
                  allow_input: Rails.env.test?, # allow Capybara to fill_in the input directly
                  wrap: true }
        }.deep_merge(options)
        format_date_values(container_options)

        @template.tag.div(**container_options) do
          @template.concat text_field(method, input_options)
          @template.concat @template.tag.span(
            @template.tag.span(@template.icon('fas', 'calendar-alt'), class: 'input-group-text'),
            class: 'input-group-append add-on', data: { open: true }
          )
        end
      end

      private

        # Maps each Ruby format to its corresponding Flatpickr format
        # See https://github.com/adrienpoly/stimulus-flatpickr/blob/master/src/strftime_mapping.js
        RUBY_TO_FLATPICKR_FORMAT_MAP = {
          '%Y' => 'Y',
          '%y' => 'y',
          '%C' => 'Y',
          '%m' => 'm',
          '%-m' => 'n',
          '%_m' => 'n',
          '%B' => 'F',
          '%^B' => 'F',
          '%b' => 'M',
          '%^b' => 'M',
          '%h' => 'M',
          '%^h' => 'M',
          '%d' => 'd',
          '%-d' => 'j',
          '%e' => 'j',
          '%H' => 'H',
          '%k' => 'H',
          '%I' => 'h',
          '%l' => 'h',
          '%-l' => 'h',
          '%P' => 'K',
          '%p' => 'K',
          '%M' => 'i',
          '%S' => 'S',
          '%A' => 'l',
          '%a' => 'D',
          '%w' => 'w'
        }.freeze

        def flatpickr_format(format: :default)
          I18n
            .translate("date.formats.#{format}",
                       default: Date::DATE_FORMATS[format.to_sym]) # fallback to Date constants
            .gsub(/%[-_^]?[[:alpha:]]/, RUBY_TO_FLATPICKR_FORMAT_MAP)
        end

        # Format any date-like values using the given format,
        # making them match the formatted expected by flatpickr/datepicker JavaScript.
        def format_date_values(options)
          options[:data]&.each do |key, value|
            options[:data][key] = I18n.localize(value.to_date, format: :default) if value.respond_to? :strftime
          end
        end
    end
  end
end
