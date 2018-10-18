# frozen_string_literal: true

# Overrides https://github.com/rails/rails/blob/master/railties/lib/rails/generators/erb/scaffold/scaffold_generator.rb
#
# See
# * http://stackoverflow.com/questions/4696954/how-to-have-the-scaffold-to-generate-another-partial-view-template-file
# * http://stackoverflow.com/questions/16320882/rails-generate-both-html-and-js-views-with-scaffold
# * http://www.softwaremaniacs.net/2014/01/replacing-scaffoldcontroller-generator.html
require 'rails/generators/erb/scaffold/scaffold_generator'

module All # :nodoc:
  module Generators # :nodoc:
    class ScaffoldGenerator < Erb::Generators::ScaffoldGenerator # :nodoc:
      puts "Source: #{__FILE__}\n"
      source_root File.join(Rails.root, 'lib', 'templates', 'erb', 'scaffold')

      protected

        def available_views
          %w[index index.xls edit show new _form _action_menu]
        end

        # Overrides https://github.com/rails/rails/blob/master/railties/lib/rails/generators/erb.rb
        def filename_with_extensions(name, format = self.format)
          file_format = name[/\.xls/] ? nil : format # format on view name overrides default
          [name, file_format, handler].reject(&:blank?).join(".")
        end
    end
  end
end
