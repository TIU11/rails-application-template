# Capistrano "Production" Stage

role :web, "production.tiu11.org"
role :app, "production.tiu11.org"
role :db,  "production.tiu11.org", :primary => true
