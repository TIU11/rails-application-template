# frozen_string_literal: true

require 'yaml'
require 'dotenv'

# TODO: how to we hook this just during initial deploy so it doesn't have to be done manually?
#
# Good examples (for Capistrano 3) at (https://github.com/capistrano-plugins/capistrano-postgresql) but not using since:
# * creates shared database.yml, but we have it in git (with secrets in .env)
# * prompts for things (to populate database.yml) but we just read them from database.yml
#
# Simple examples (for Capistrano 2):
# * (https://github.com/railscasts/373-zero-downtime-deployment/blob/master/blog-after/config/recipes/postgresql.rb)
# * (https://github.com/mattdbridges/capistrano-recipes/blob/master/postgresql.rb)

namespace :postgresql do

  desc "Create a database for this application."
  task create_database: :initialize_params do
    on roles(:db) do
      if test :sudo, '-u postgres',
              %(psql -tAc "SELECT 1 FROM pg_database WHERE datname='#{fetch(:pg_database)}';" | grep -q 1)
        info "#{fetch(:pg_database)} database already exists"
      elsif execute :sudo, '-u postgres',
                    %(psql -c "CREATE DATABASE \\"#{fetch(:pg_database)}\\" OWNER \\"#{fetch(:pg_user)}\\";")
        info "Created #{fetch(:pg_database)}"
      else
        error "Failed to create #{fetch(:pg_database)} database"
        exit 1
      end
    end
  end

  desc "Create database user"
  task create_db_user: :initialize_params do
    on roles(:db) do
      if test :sudo, '-u postgres',
              %(psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='#{fetch(:pg_user)}';" | grep -q 1)
        info "#{fetch(:pg_user)} already exists"
      elsif execute :sudo, '-u postgres',
                    %(psql -c "CREATE USER \\"#{fetch(:pg_user)}\\" WITH PASSWORD '#{fetch(:pg_password)}';")
        info "Created #{fetch(:pg_user)}"
      else
        error "Failed to create database user '#{fetch(:pg_user)}'"
        exit 1
      end
    end
  end

  task :setup do
    invoke 'postgresql:create_db_user'
    invoke 'postgresql:create_database'
  end

  task :initialize_params do
    on roles(:db) do
      remote_env = Dotenv::Parser.call(capture("cat #{shared_path}/.env"))
      ENV['DATABASE_PASSWORD'] = remote_env['DATABASE_PASSWORD']

      config = YAML.safe_load(ERB.new(File.read('config/database.yml')).result)[fetch(:rails_env).to_s]

      set :pg_host, config['host'] || 'localhost'
      set :pg_user, config['username']
      set :pg_database, config['database']
      set :pg_password, config['password']
    end
  end

end
