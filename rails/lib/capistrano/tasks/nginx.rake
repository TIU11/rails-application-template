# frozen_string_literal: true

require 'colorize'

# See https://github.com/railscasts/373-zero-downtime-deployment/blob/master/blog-after/config/recipes/nginx.rb

namespace :nginx do

  desc "Setup nginx configuration for this application"
  task :setup do
    on roles(:web) do
      fqdn = "#{fetch(:application)}-#{fetch(:rails_env)}.#{fetch(:top_level_domain)}"
      config_path = "/etc/nginx/sites-available/#{fqdn}"

      if test "[ -f #{config_path} ]"
        info "Nginx configuration exists. To regenerate, simply delete #{config_path}"
      else
        passenger_ruby = capture(:rvm, "#{fetch(:rvm_ruby_version)} do",
                                 '/usr/bin/passenger-config --ruby-command',
                                 "| grep -o 'passenger_ruby.*'").strip

        template_path = 'lib/capistrano/templates/nginx_passenger.erb'
        content = StringIO.new(ERB.new(File.read(template_path), trim_mode: '>').result(binding)) # process ERB template
        upload! content, "#{shared_path}/#{fqdn}"

        execute :sudo, :mv, "#{shared_path}/#{fqdn} #{config_path}"
        info "Uploaded #{config_path} created from #{template_path}".cyan.bold

        execute :sudo, :ln, "-fs /etc/nginx/sites-available/#{fqdn} /etc/nginx/sites-enabled/#{fqdn}"
        invoke 'nginx:reload'
        info "Enabled nginx config. If DNS is configured, try browsing http://#{fqdn}".cyan.bold
      end
    end
  end

  %w[start stop restart reload].each do |command|
    desc "#{command} nginx"
    task command do
      on roles(:web) do
        execute :sudo, "service nginx #{command}"
      end
    end
  end

end
