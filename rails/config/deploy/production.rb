# frozen_string_literal: true

# TODO: Specify proxy if needed
# set :default_env, http_proxy: 'http://172.16.x.x:xxxx'

server 'production.tiu11.org', user: fetch(:user), roles: %w[web app], ssh_options: {
  forward_agent: true,
  auth_methods: %w[publickey]
}

server 'database.tiu11.org', user: fetch(:user), roles: %w[db], no_release: true

# Parallelize the installation of gems.
# Choose a number less or equal than the number of cores your server.
set :bundle_jobs, 4
