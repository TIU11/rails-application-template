# Capistrano "Demo" Stage

set :rails_env, "dev"

role :web, "dev.tiu11.org"
role :app, "dev.tiu11.org"
role :db,  "dev.tiu11.org", :primary => true
