class Authlogic::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :attributes, type: :array,
      default: ['email:string', 'first_name:string', 'last_name:string'],
      banner: "field:type field:type"

  # Every method that is declared below will be automatically executed when the generator is run

  def create_users
    generate "scaffold user #{ attributes.join(' ') } --no-stylesheets --no-javascripts --no-helper --force"
    inject_into_class 'app/controllers/users_controller.rb', UsersController, "  load_and_authorize_resource\n"
  end

  def copy_templates
    directory 'app'
    directory 'spec'
    directory 'config'
    route open_template('routes.rb.delta').read
    insert_into_file Dir['db/migrate/*_create_users.rb'].first,
                     open_template('create_users.rb.delta').read,
                     before: "\n      t.timestamps null: false"
    insert_into_file 'app/views/shared/_nav.html.erb',
                     "        <%= render 'shared/login_menu' %>\n",
                     before: '      </div><!--/.nav-collapse -->'
  end

  private

  def open_template(template_path)
    File.open File.join(File.dirname(__FILE__), 'templates', template_path)
  end

end
