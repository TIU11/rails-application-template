module Angularjs
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    # Every method that is declared below will be automatically executed when the generator is run

    def install
      insert_into_file 'app/assets/javascripts/application.js',
                       "//= require angular/index\n",
                       after: "//= require jquery_ujs\n"
      gem 'angularjs-rails'
      get "https://raw.github.com/angular-ui/bootstrap/gh-pages/ui-bootstrap-tpls-0.9.0.js",
          "vendor/assets/javascripts/ui-bootstrap-tpls-0.9.0.js"
    end

    def copy_templates
      # TODO: 1-file-per-controller
      # Check out http://coderberry.me/blog/2013/04/23/angularjs-on-rails-4-part-2/
      directory 'app'
    end

    private

    def open_template(template_path)
      File.open File.join(File.dirname(__FILE__), 'templates', template_path)
    end

  end
end
