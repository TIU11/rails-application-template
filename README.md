# Overview

Bootstraps a Rails project, with customizations beyond a default `rails new myApp`.

# Prerequisites

First, update to the latest version of Rails (or you'll want to run `rake rails:update` when you do)

    gem install rails -v "~> 4.1.0" # 4.1.x latest
    gem install rails -v "~> 3.2.0" # 3.2.x latest (deprecated...dropping Rails 3.2 conditionals in next release)
    gem install rails               # or the latest, period.
    gem install bundler             # Rails 4.0.2 depends on bundler (< 2.0, >= 1.3.0)
                                    # We've noticed bundler 1.7 is much faster than 1.3

This template assumes some things:

* RVM ~> 1.20 is installed

        # See http://rvm.io/rvm/install
        \curl -sSL https://get.rvm.io | bash -s stable --rails

        # Upgrade with
        rvm get stable && rvm reload
* XCode and command line tools (GCC needed to compile some gems)

        > rvm requirements
        Checking requirements for osx.
        Requirements installation successful.
* SSH keys are configured so access to dev.tiu11.org doesn't prompt for a password
* dev.tiu11.org has an SSH public key, and this is the desired Bitbucket deployment key
* dev.tiu11.org also has RVM (~> 1.20) installed

# Getting Started

Generate! Choose your application name carefully, since a lot of work will be done using this name.

    rails new myApp -m https://bitbucket.org/tiu/rails-application-template/raw/master/template.rb
    cd myApp
    bundle outdated              # See if the template has you stuck on some old, crusty code
    rake db:migrate
    rails server
    open http://lvh.me:3000

To see what the template does, you may wish to first generate a default app:

    rails new myApp
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

* `cap dev deploy:setup`
* create .env in `{deploy_to}/shared/.env` with the correct passwords, etc.
* `cap dev deploy`

# Todo

* Upgrade to [Capistrano 3](http://www.capistranorb.com/2013/06/01/release-announcement.html)
* Updates for Rails 4.0
* Automate setup/deploy to dev.tiu11.org

# Credits

Developed by Anson Hoyt at [Tuscarora Intermediate Unit 11](http://www.tiu11.org).

# License

Copyright (c) 2013 [Tuscarora Intermediate Unit 11](http://www.tiu11.org).
See LICENSE for details.
