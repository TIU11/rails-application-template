# Overview

Bootstraps a Rails project, with customizations beyond a default `rails new myApp`.

# Prerequisites

This template assumes some things:

* RVM is installed and up-to-date (1.26.x)

        # See http://rvm.io/rvm/install
        \curl -sSL https://get.rvm.io | bash -s stable --rails

        # Upgrade with
        rvm get stable && rvm reload

* Ruby 2.2.x is installed

        rvm install 2.2

* Rails 4.2.x is installed

        rvm use 2.2
        gem install rails               # install latest version of rails
        gem install rails -v "~> 4.2.1" # you may install an older version, but the template is more likely to not work.

* Bundler and RubyGems are up-to-date (optional)

        gem install bundler             # Rails 4.0.2 depends on bundler (< 2.0, >= 1.3.0)
                                        # We've noticed bundler 1.7 is much faster than 1.3
        gem update --system             # Per https://rubygems.org/pages/download

* XCode and command line tools (GCC needed to compile some gems)

    > rvm requirements
    Checking requirements for osx.
    Requirements installation successful.

* SSH keys are configured so access to dev.tiu11.org doesn't prompt for a password
* dev.tiu11.org has an SSH public key, and this is the desired Bitbucket deployment key
* dev.tiu11.org also has RVM (~> 1.26) installed

# Getting Started

Generate! Choose your application name carefully, since a lot of work will be done using this name.

    cd ~/code                    # Wherever you put your projects
    rvm use 2.2
    rails new myApp -m https://bitbucket.org/tiu/rails-application-template/raw/master/template.rb --database=postgresql --skip-turbolinks
    cd myApp
    bundle outdated              # See if the template has you stuck on some old, crusty code
    rake db:migrate
    rails server
    open http://lvh.me:3000

To see what the template does, you may wish to first generate a default app:

    rails new myApp --database=postgresql
    cd myApp
    git init
    git add .
    git commit -m "Initialized with `rails new`"
    cd ..
    rails new myApp -m https://bitbucket.org/tiu/rails-application-template/raw/master/template.rb

# Post-setup

* tidy up the Gemfile
* add dev, demo, production deployment keys to Bitbucket
* check environment configs
** update hostnames for dev, demo, production servers in config/deploy/<environment>.rb
** make sure environments defined in secrets.yml, database.yml, config/environments/<environment>.rb
* update local `.env` and only check it in if you use example/development settings that won't reveal demo/production settings!

# Initial Deploy to Dev/Demo/Production Environment

* `cap dev deploy` # with each run, the error message point to the following manual steps
* create .env in `{deploy_to}/shared/.env` with the correct passwords, etc. for that environment
* create rvm gemset using the suggested command
* create database user and database matching `database.yml`. Copy the commands from `postgresql.rake`
* `cap dev deploy` until it completes successfully

# Todo

* Automate more stuff with [Capistrano 3](http://www.capistranorb.com/2013/06/01/release-announcement.html)
* Automate more of the setup/deploy to dev.tiu11.org
 - initialize .env
 - create database user, database
 - create nginx config
* Don't install gems in current gemset, just in the RVM one created for the project
* Consider adding some of these: https://intercityup.com/blog/useful-capistrano-plugins.html?utm_source=rubyweekly&utm_medium=email

# Credits

Developed by Anson Hoyt at [Tuscarora Intermediate Unit 11](http://www.tiu11.org).

# License

Copyright (c) 2015 [Tuscarora Intermediate Unit 11](http://www.tiu11.org).
See LICENSE for details.
