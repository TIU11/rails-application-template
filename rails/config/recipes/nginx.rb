namespace :nginx do
  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    template "nginx_passenger.erb", "/tmp/nginx_conf"
    run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-available/#{application}.#{top_level_domain}"
    run "#{sudo} ln -fs /etc/nginx/sites-available/#{application}.#{top_level_domain} /etc/nginx/sites-enabled/#{application}.#{top_level_domain}"
    run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end
