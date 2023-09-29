# Overview

Bootstraps a Rails project, with customizations beyond a default `rails new my-app`.

# Prerequisites

This template assumes some things:

* RVM is installed and up-to-date (1.29.x)
  on your mac

        # See http://rvm.io/rvm/install
        gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
        \curl -sSL https://get.rvm.io | bash -s stable

        # Upgrade with
        rvm get stable && rvm reload

    and on the server, just execute with `sudo` to install system-wide

        \curl -sSL https://get.rvm.io | sudo bash -s stable

* Ruby 2.7+ is installed (3.2 recommended)

    for Ruby 3.1+:

        rvm install 3.2

    for Ruby > 2.4, < 3.1.0: ([needs OpenSSL 1.1](https://stackoverflow.com/a/76680088/1178927))

        brew install openssl@1.1
        export PKG_CONFIG_PATH="$(brew --prefix openssl@1.1)/lib/pkgconfig" # if needed
        rvm install 2.7.8 --with-openssl-dir=$(brew --prefix openssl@1.1)

* Rails 6.0+ is installed (7.0 recommended)

        rvm use 3.2.2
        gem install rails               # install latest version of rails
        gem install rails -v "~> 4.2.7" # you may install an older version, but the template is very likely to not work. Some things require rails 5.2+

* Bundler and RubyGems are up-to-date

    ([mini_racer](https://github.com/rubyjs/mini_racer#troubleshooting) requires Rubygems >= 3.2.13 and bundler >= 2.2.13)

    For ruby 2.6 and above (which [now includes bundler](https://stdgems.org/new-in/2.6/))

        gem update bundler
        gem update --system                 # Per https://rubygems.org/pages/download
        bundle update --bundler             # Update "bundled with" in Gemfile.lock

    Gems with native extensions may need the compatible platforms set in `Gemfile.lock`.
    See [bundle platform](https://bundler.io/v2.3/man/bundle-platform.1.html).

        bundle lock --add-platform ruby         # optional fallback. likely unnecessary with Bundler 2.3+
        bundle lock --add-platform x86_64-linux # our servers
        bundle lock --add-platform aarch64-linux # our VMs
        bundle lock --add-platform arm64-darwin # our development machines

* Node.js with nvm

    For apps using jsbundling-rails with esbuild (or still using webpacker).

        echo "lts/*" > .nvmrc # Use the latest LTS version. See `nvm ls-remote --lts`.
        nvm alias default lts/* # Consider making this the default for new shells
        nvm install --latest-npm
        npm install --global yarn@latest

    NOTE: On Apple Silicon, use node 16.0+, or stick with `x86_64` as per [nvm](https://github.com/nvm-sh/nvm#macos-troubleshooting). Check your arch with `file $(which node)`.

* Expects `pg` 1.x which requires PostgreSQL 9.3+. To use another database, you'll need to make a few config changes.

        brew install postgresql

* XCode and command line tools (GCC needed to compile some gems)

        > rvm requirements
        Checking requirements for osx.
        Requirements installation successful.

* SSH keys are configured so access to dev.tiu11.org doesn't prompt for a password
* dev.tiu11.org has an SSH public key, and this is the desired Bitbucket deployment key
* dev.tiu11.org also has RVM (~> 1.29) installed

# Getting Started

Choose your application name carefully, since a lot of work will be done using this name (e.g. repo name, folder name, urls, server configuration, etc.).

To see what the template does, we like to first generate a default rails app and commit it to git as a baseline for comparison. (optional)

    cd ~/code                    # Wherever you put your projects
    rvm use 3.2.2
    rails new                    # learn what the various options do
    rails new my-app --database postgresql --skip-active-storage --javascript esbuild --no-scaffold-stylesheet
    cd my-app
    git init # rails does this for you
    git add .
    git commit -m "Initialized with 'rails new'"

Some options are pretty standard, so make them defaults:

    # ~/.railsrc
    --database postgresql
    --javascript esbuild
    --no-scaffold-stylesheet

Finally, apply this template:

    cd ~/code                    # Wherever you put your projects
    rails new my-app --template https://bitbucket.org/tiu/rails-application-template/raw/master/template.rb --database postgresql --skip-active-storage --no-scaffold-stylesheet --force

Look over what the template added to the default app. You might spot something that could be improved in the template.

That's it, take her for a spin:

    cd my-app
    rails server                # Start the server (older projects not using jsbundling-rails)
    bin/dev                     # Start the Procfile
    open http://localhost:3000  # Launch in your browser

# Post-setup

* add ~dev, demo~, production deployment keys to Bitbucket
* review `Gemfile` (replace gems you may have added)
* review the environment configs: `development`, `dev`, `demo`, `production` (`dev` and `demo` are copies of production)
    * `config/environments/<environment>.rb`
    * `config/database.yml`
    * `config/deploy/<environment>.rb` (update hostnames)
* update `.env` (but don't check it in!) and `.env.sample` (and *do* check it in)
* update `default_host` in `config/sitemap.rb` with your production url

# Initial Deploy to Dev/Demo/Production Environment

* Review your Capistrano configuration in `deploy.rb`.
* `cap dev rvm:create_gemset` (separate from `deploy:setup`...for now)
* `cap dev deploy:setup`
* `cap dev deploy` # with each run, an error will point out something that you need to address (e.g. a manual step, a missing dependency for a gem with native extensions, etc)
* `cap dev deploy` until it completes successfully
* `cap production rake[db:seed]`

# Updating an existing Application

* `rails app:template LOCATION=https://bitbucket.org/tiu/rails-application-template/raw/master/template.rb`

# Todo

* Extract Bootstrap 3/4 stuff to v1/v2 of `app:setup` generator.
* Reconsider Turbolinks 6 (ETA fall 2020) as perhaps more drop-in WRT form handling and more approachable.
* Consider ideas from [Suspenders](https://github.com/thoughtbot/suspenders) and [Potassium](https://github.com/platanus/potassium) ([RW#563](https://rubyweekly.com/issues/563)).
* still needs font-awesome-migrator to be applied to the template. Might be good to notify folks to run on their projects if they were depending on FA 4.x
* useful default `README.md`
* define TLD and FQDN centrally, then use it everywhere
* automate initial deploy
    * refactor `rvm:create_gemset` so it doesn't need to be invoked separately
    * run `deploy:setup` for initial setup automatically when deploying for the first time?
* improve Bitbucket repository stuff
    * initialize Bitbucket smarter and w/o prompts (are better APIs exposed since we wrote?)
    * setup deploy keys independently, perhaps as a rake task, so it works for checking on existing repos
* Scaffold the controller a bit more fully (e.g. define formats with [responders](https://github.com/plataformatec/responders), especially for .xls with set_filename)
* Consider Custom Form Builder to "Bootstrappify" error state, required fields, labelled fields, etc.
* Consider adding some of these:
    * (https://github.com/mattbrictson/rails-template)
    * (https://intercityup.com/blog/useful-capistrano-plugins.html?utm_source=rubyweekly&utm_medium=email)
    * (http://blog.rubyroidlabs.com/2016/02/capistrano-tools/)
* consider mentioning .railsrc, like (http://pixelatedworks.com/articles/configuring_new_rails_projects_with_railsrc_and_templates/?utm_source=rubyweekly&utm_medium=email)

# Credits

Developed by Anson Hoyt at [Tuscarora Intermediate Unit 11](http://www.tiu11.org).

# License

Copyright (c) [Tuscarora Intermediate Unit 11](http://www.tiu11.org).
See [LICENSE](LICENSE.md) for details.
