# Capistrano "Demo" Stage

set :rails_env, "demo"

role :web, "demo.tiu11.org"
role :app, "demo.tiu11.org"
role :db,  "demo.tiu11.org", :primary => true
