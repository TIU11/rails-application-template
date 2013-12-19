# Overview

Bootstraps a Rails project, with customizations beyond a default `rails new myApp`.

# Getting Started

First, update to the latest version of Rails (or you'll want to run `rake rails:update` when you do)

    # 3.2.x latest
    gem install rails -v "~> 3.2.0"
    # or the latest, period.
    gem install rails

Generate! Choose your application name carefully, since a lot of work will be done using this name.

    rails new myApp -m https://bitbucket.org/tiu/rails-application-template/raw/master/template.rb
    cd myApp
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

Assumes some things:

* RVM ~> 1.20 and Rails ~> 3.2.x are installed
    # see http://rvm.io/rvm/install
    \curl -sSL https://get.rvm.io | bash -s stable --rails
* XCode and command line tools (GCC needed to compile some gems)
* SSH keys are configured, so access to dev.tiu11.org doesn't prompt for a password
* dev.tiu11.org has an SSH public key, and this is the desired Bitbucket deployment key
* dev.tiu11.org has RVM (~> 1.20) installed

# Post-setup

    rvm --ruby-version use 1.9.3@my_app # generates .ruby-version and .ruby-gemset
    tidy up the Gemfile
    add dev, demo, production deployment keys to Bitbucket
    update hostnames for dev, demo, production servers in config/deploy/<environment>.rb

# Credits

Developed by Anson Hoyt at [Tuscarora Intermediate Unit 11](http://www.tiu11.org).

# License

Copyright (c) 2013 [Tuscarora Intermediate Unit 11](http://www.tiu11.org).
See LICENSE for details.
