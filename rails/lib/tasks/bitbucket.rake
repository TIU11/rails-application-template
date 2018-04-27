# frozen_string_literal: true

require 'colorize'

namespace :bitbucket do

  # Create Bitbucket Repository
  # @see (https://confluence.atlassian.com/bitbucket/repository-resource-423626331.html#repositoryResource-POSTanewrepository)
  task create: :environment do |_task, _args|
    app_name = Rails.application.class.parent_name.titleize
    data = {
      scm: 'git',
      is_private: true,
      fork_policy: 'allow_forks',
      name: app_name,
      language: 'ruby'
    }
    repo_slug = app_name.parameterize
    owner = 'tiu'

    puts "Creating Bitbucket repository #{owner}/#{repo_slug}".cyan

    abort 'goodbye' unless Bitbucket.username

    # Create the Bitbucket repository
    `curl --request POST --user '#{Bitbucket.credentials}' \
          --header 'Content-Type: application/json' --data '#{data.to_json}' \
          https://bitbucket.org/api/2.0/repositories/#{owner}/#{repo_slug}`

    # Set the remote and push
    `git remote add origin git@bitbucket.org:#{owner}/#{repo_slug}.git`
    # TODO: any reason we used to use SSH for the remote?
    # `git remote add origin ssh://git@bitbucket.org/#{owner}/#{repo_slug}.git`

    `git push -u origin --all` # pushes up the repo and its refs for the first time
    `git push -u origin --tags` # pushes up any tags
  end

  # Add deploy keys to Bitbucket repository for the following hosts: dev, demo
  # @see (https://confluence.atlassian.com/bitbucket/deploy-keys-resource-296095243.html#deploy-keysResource-POSTanewkey)
  task add_deploy_keys: :environment do |_task, _args|
    hosts = ['dev.tiu11.org', 'demo.tiu11.org']

    hosts.each do |host|
      puts "Retrieving public key from #{host}"
      key = `ssh #{host} "cat ~/.ssh/id_rsa.pub"`
      label = key.split(' ')[2]
      data = { key: key, label: label }
      puts "Uploading to bitbucket"
      `curl --request POST \
            --user '#{Bitbucket.credentials}' \
            --header 'Content-Type: application/json' \
            --data '#{data.to_json}' \
            https://bitbucket.org/api/1.0/repositories/#{Bitbucket.owner}/#{Bitbucket.repo_slug}/deploy-keys`
    end
  end

  # Open in SourceTree (assumes command line is already installed)
  # Not cross-platform compatible.
  # @see (http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby)
  # @see (http://stackoverflow.com/questions/19663202/how-do-you-open-sourcetree-from-the-command-line)
  task :launch_sourcetree do |_task, _args|
    if `which stree`.present?
      `stree`
    else
      puts "Go install the SourceTree Command Line Tools. Simply launch SourceTree, "\
           "open the SourceTree menu, and select \"Install Command Line Tools\".".yellow
      `open -a SourceTree #{Rake.application.original_dir}`
    end
  end

  desc 'Initialize repository and set remote origin'
  task setup: :environment do |_task, _args|
    puts `git init`

    if Bitbucket.repo_slug
      puts "Project already has a Bitbucket repository as remote origin...skipping creation".green
    else
      puts "No Bitbucket repository set as remote origin"
      Rake::Task['bitbucket:create'].invoke
    end

    Rake::Task['bitbucket:add_deploy_keys'].invoke
  end
end
