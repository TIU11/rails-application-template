namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Change group to www-data"
  task :update_group, :roles => [ :app, :db, :web ] do
    run "sudo chown -Rh `whoami`:www-data #{deploy_to}"
    run "sudo chmod -R g+w #{deploy_to}"
  end
end
