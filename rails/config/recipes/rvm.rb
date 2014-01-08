# RVM integration
# See http://beginrescueend.com/integration/capistrano/

set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
set :rvm_type, :system
require "rvm/capistrano"
require "rvm/capistrano/gem_install_uninstall"

ENV['GEM'] = "bundler"
before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'
before 'deploy:setup', 'rvm:install_gem'
