module Helpers
  module TextHelper
    class << self

      # Returns +text+ transformed into HTML using simple formatting rules.
      # One or more newlines are turned into paragraphs
      #
      # Alternative to ActionView::Helpers::TextHelper.simple_format
      def format_lines(text, wrapper_tag: :p)
        text = ApplicationController.helpers.sanitize(text)
        lines = split_lines(text)

        if lines.empty?
          ApplicationController.helpers.content_tag wrapper_tag, nil
        else
          lines.map! do |line|
            ApplicationController.helpers.content_tag(wrapper_tag, ApplicationController.helpers.raw(line))
          end.join("\n")
        end
      end

      def split_lines(text)
        return [] if text.blank?
        text.to_str.gsub(/\r\n?/, "\n").split(/\n+/)
      end

    end
  end
end
