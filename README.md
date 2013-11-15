# Overview

Bootstraps a Rails project, with customizations beyond a default `rails new myApp`.

# Getting Started

    rails new myApp -m https://bitbucket.org/tiu/rails-application-template/raw/master/template.rb

To see what the template does, you may wish to first generate a default app:

    rails new myApp
    cd myApp
    git init
    git add .
    git commit -m "Initialized with `rails new`"
    cd ..
    rails new myApp -m https://bitbucket.org/tiu/rails-application-template/raw/master/template.rb

# Post-setup

    rvm --ruby-version use 1.9.3@my_app # generates .ruby-version and .ruby-gemset

# Credits

Developed by Anson Hoyt at [Tuscarora Intermediate Unit 11](http://www.tiu11.org).

# License

Copyright (c) 2013 [Tuscarora Intermediate Unit 11](http://www.tiu11.org).
See LICENSE for details.
