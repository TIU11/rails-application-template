class Authlogic::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :attributes, :type => :array, :default => ['email:string', 'first_name:string', 'last_name:string'], :banner => "field:type field:type"

  # Every method that is declared below will be automatically executed when the generator is run

  def create_sessions
    generate 'session_migration --no-stylesheets --no-javascripts --no-helper'
    uncomment_lines 'config/initializers/session_store.rb', ":active_record_store"
    comment_lines 'config/initializers/session_store.rb', ":cookie_store"
  end

  def create_users
    generate "scaffold user #{ attributes.join(' ') } --no-stylesheets --no-javascripts --no-helper"
    insert_into_file 'app/models/user.rb', open_template('user.rb.delta').read, before: "end\n"
    inject_into_class 'app/controllers/users_controller.rb', UsersController, "  load_and_authorize_resource\n"
  end

  def copy_templates
    directory 'app'
    route open_template('routes.rb.delta').read
    insert_into_file Dir['db/migrate/*_create_users.rb'].first, open_template('create_users.rb.delta').read, before: 't.timestamps'
    insert_into_file 'app/views/shared/_nav.html.erb', "        <%= render 'shared/login_menu' %>\n", before: '      </div><!--/.nav-collapse -->'
  end

  private

  def open_template(template_path)
    File.open File.join(File.dirname(__FILE__), 'templates', template_path)
  end

end
