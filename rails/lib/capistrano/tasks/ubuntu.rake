namespace :ubuntu do

  desc 'Install Ubuntu package dependencies for this application'
  task :setup do
    # @see (http://stackoverflow.com/questions/1298066/check-if-a-package-is-installed-and-then-install-it-if-its-not)

    # build list of package dependencies
    application_gems = `bundle list`
    required_packages = []
    required_packages << 'libpq-dev' if application_gems =~ /\* pg /
    required_packages << 'libgmp-dev' if application_gems =~ /\* json /

    # install packages on web server
    on roles(:web) do
      info "Ensuring these required package dependencies are installed: #{required_packages.join(', ')}"
      required_packages.each do |package|
        # check if already installed
        if test %{dpkg-query -W --showformat='${Status}\n' #{package} | grep -q 'install ok installed'}
          info "#{package} already installed"
        # attempt to install
        elsif test :sudo, %{apt-get --yes install #{package}}
          info "#{package} has been installed"
        else
          error "There was a problem installing #{package}"
          exit 1
        end
      end
    end
  end

end
