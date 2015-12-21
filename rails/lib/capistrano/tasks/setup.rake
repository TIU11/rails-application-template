namespace :deploy do
  # Initial server setup. Requires sudo access.
  # TODO: use daemons that can handle this without root-level permissions
  task :setup do
    invoke 'deploy:check'
    invoke 'postgresql:setup'
    invoke 'nginx:setup'
  end
end
