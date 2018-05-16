# frozen_string_literal: true

require 'byebug'

module Tiu
  class InstallTypeaheadGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def add_gem
      gem 'twitter-typeahead-rails', '~> 0.11.0'
      append_to_file 'Gemfile', ' # Twitter typeahead jQuery plugin'
    end

    def copy_files
      directory 'app'
      directory 'vendor'
    end

    def load_assets
      insert_into_file "app/assets/javascripts/application.js", <<~JS, after: "//= require bootstrap-datepicker\n"
        //= require twitter_typeahead
        //= require twitter/typeahead
      JS

      insert_into_file "app/assets/stylesheets/application.css",
                       " *= require typeahead\n",
                       after: "*= require bootstrap-datepicker3\n"
    end

  end
end
