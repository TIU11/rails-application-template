# frozen_string_literal: true

require 'helpers/generator_helper'

module Authlogic
  class InstallGenerator < Rails::Generators::Base
    include ::Helpers::GeneratorHelper
    source_root File.expand_path('templates', __dir__)
    argument :attributes, type: :array,
                          default: ['email:string', 'first_name:string', 'last_name:string'],
                          banner: "field:type field:type"

    # Every method that is declared below will be automatically executed when the generator is run

    def create_users
      generate "scaffold user #{attributes.join(' ')} --no-stylesheets --no-javascripts --no-helper --force"
      inject_into_class 'app/controllers/users_controller.rb', UsersController, "  load_and_authorize_resource\n"
    end

    def copy_templates
      directory 'app'
      directory 'spec'
      directory 'config'
    end

    def update_files
      route read_template('routes.rb.delta')
      insert_into_file "#{destination_root}/app/assets/javascripts/application.js",
                       "//= require sprintf\n",
                       after: "//= require bootstrap-datepicker\n"
      insert_into_file Dir['db/migrate/*_create_users.rb'].first,
                       open_template('create_users.rb.delta').read,
                       before: "\n      t.timestamps"
      insert_into_file 'app/views/application/_nav.html.erb',
                       "        <%= render 'login_menu' %>\n",
                       before: '      </div><!--/.nav-collapse -->'
      end

  end
end
