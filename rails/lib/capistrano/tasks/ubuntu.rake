# frozen_string_literal: true

namespace :ubuntu do

  desc 'Install Ubuntu package dependencies for this application'
  task :setup do
    # @see (http://stackoverflow.com/questions/1298066/check-if-a-package-is-installed-and-then-install-it-if-its-not)

    # define gem dependencies on ubuntu packages
    known_gem_dependencies = {
      activestorage: [
        'ffmpeg', # If you are dealing with video
        'poppler-utils', # If you are dealing with PDFs (GNU licensed option. Free for commercial use.)
        'imagemagick',
        'libvips-tools' # vips
      ],
      pg: [
        'libpq-dev',
        'postgresql-client' # db:snapshot task uses `pg_dump`
      ],
      json: 'libgmp-dev',
      charlock_holmes: 'libicu-dev',
      mimemagic: 'shared-mime-info',
      paperclip: [
        'imagemagick',
        # If you are dealing with pdf uploads:
        'ghostscript',
        'libgs-dev'
      ],
      carrierwave: 'imagemagick',
      tiny_tds: [
        'build-essential',
        'libc6-dev'
      ],
      rgeo: [
        'libgeos-dev', # GEOS 3.3.3+ recommended
        'libproj-dev' # Proj 4.7+ recommended
      ],
      webpacker: 'yarn'
    }

    # build list of package dependencies
    application_gems = `bundle list`
    required_packages = []

    known_gem_dependencies.each do |gemname, package_names|
      if application_gems.match?(/\* #{gemname} /)
        required_packages.push(*package_names) # add package(s) to install
      end
    end

    # install packages on web server(s)
    on roles(:web) do
      info "Ensuring these required package dependencies are installed: #{required_packages.join(', ')}"
      required_packages.each do |package|
        # check if already installed
        if test %(dpkg-query -W --showformat='${Status}\n' #{package} | grep -q 'install ok installed')
          info "#{package} already installed"
        # attempt to install
        elsif test :sudo, %(apt-get --yes install #{package})
          info "#{package} has been installed"
        else
          error "There was a problem installing #{package}"
          exit 1
        end
      end
    end
  end

end
