namespace :apache2 do

  # https://www.phusionpassenger.com/docs/advanced_guides/install_and_upgrade/apache/install/oss/focal.html
  desc "Setup Apache configuration for this application"
  task :setup do
    on roles(:web) do
      # TODO: fqdn looks wrong. Why not read from application config?
      fqdn = "#{fetch(:application)}-#{fetch(:rails_env)}.#{fetch(:top_level_domain)}"
      config_path = "/etc/apache2/sites-available/#{fqdn}"

      if test "[ -f #{config_path} ]"
        info "Apache configuration exists. To regenerate, simply delete #{config_path}"
      else
        passenger_ruby = capture(
          :rvm, fetch(:rvm_ruby_version), "do /usr/bin/passenger-config --ruby-command | rg 'Command: (.*)' -or '$1'"
        ).strip

        template_path = 'lib/capistrano/templates/apache_passenger.erb'
        content = StringIO.new(ERB.new(File.read(template_path), trim_mode: '>').result(binding)) # process ERB template
        upload! content, "#{shared_path}/#{fqdn}"

        execute :sudo, :mv, "#{shared_path}/#{fqdn} #{config_path}"
        info "Uploaded #{config_path} created from #{template_path}".cyan.bold

        execute :sudo, :ln, "-fs /etc/apache2/sites-available/#{fqdn} /etc/apache2/sites-enabled/#{fqdn}"
        invoke 'apache2:reload'
        info "Enabled apache config. If DNS is configured, try browsing http://#{fqdn}".cyan.bold
      end
    end
  end

  %w[start stop restart reload].each do |command|
    desc "#{command} apache2"
    task command do
      on roles(:web) do
        execute :sudo, "service apache2 #{command}"
      end
    end
  end
end
