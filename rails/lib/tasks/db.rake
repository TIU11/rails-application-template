require 'colorize'

# Warning! When db:drop or db:create fail, they swallow the exception so execution does not stop.
# So, if db:drop fails, it will continue (and therefore fail) with db:create and db:restore tasks.
# A fix may land in rails 5.0.0.
# @see (https://github.com/rails/rails/pull/19924)
#
# http://dkeskar.com/iden/2010/01/07/ui-driven-database-snapshot-restore.html
# http://stackoverflow.com/questions/18723675/how-to-backup-restore-rails-db-with-postgres

namespace :db do

  desc 'Store a snapshot of the database in db/snapshots (options: NAME=x.sql)'
  task :snapshot => ['db:load_configuration', :environment] do
    stamp = Time.now.strftime('%F-%H%M%S')
    dir = ENV["DIR"] || "db/snapshots"
    file = ENV["NAME"] || "#{stamp}-#{Rails.env}-snapshot.sql"
    path = File.expand_path(file, dir)

    Dir.mkdir(dir) unless Dir.exist? dir

    options = ARGV.drop_while{|i| i != '--'}.drop(1).join(' ')
    puts "Passing extra arguments to pg_dump: #{options}".cyan if options

    sh %{
      pg_dump
        --host=#{ENV['PGHOST']}
        --username=#{ENV['username']}
        #{options}
        "#{ENV['PGDATABASE']}" > #{path}
    }.gsub(/\s+/, " ")
  end

  desc "Load database from a previously stored snapshot, 'rake db:restore[filename.sql]'"
  task :restore, [:filename] => ['db:load_configuration', 'db:snapshot', 'db:drop', 'db:create', :environment] do |t, args|
    dir = ENV["DIR"] || "db/snapshots"
    filename = args[:filename]

    Dir.mkdir(dir) unless Dir.exist? dir

    if filename
      path = File.expand_path(filename, dir)

      sh %{
        psql
          --host=#{ENV['PGHOST']}
          --username=#{ENV['username']}
          #{ENV['PGDATABASE']} < #{path}
      }.gsub(/\s+/, " ")

    else
      $stderr.puts "No snapshot name provided. Nothing to do.\n"
      $stderr.puts "Available snapshots:"
      $stderr.puts `ls #{dir}`
    end
  end

  # http://stackoverflow.com/questions/2369744/rails-postgres-drop-error-database-is-being-accessed-by-other-users
  # Rails will probably complain, but reloading the page re-establishes the connection
  desc "Terminate all active connections to the database! Tread carefully."
  task :kill_connections => ['db:load_configuration', :environment] do
    command = %{
      ps xa \
        | grep "postgres:\\s#{ENV['username']} #{ENV['PGDATABASE']}" \
        | awk '{print $1}' \
        | sudo xargs kill
    }.strip
    puts command
    `#{command}`

    # TODO: could be improved, perhaps...
    # ps xao pid,user,command | grep "postgres:\\s#{ENV['username']} #{ENV['PGDATABASE']}"
    # pgrep -f "postgres:\\s#{ENV['username']} #{ENV['PGDATABASE']}"
    # Process.kill('KILL', pid) # http://autonomousmachine.com/posts/2011/6/2/cleaning-up-processes-in-ruby
    # pkill -f "postgres:\\s#{ENV['username']} #{ENV['PGDATABASE']}"
  end

  task :load_configuration => :environment do
    dbconf = ActiveRecord::Base.configurations[Rails.env]
    ENV['PGPASSWORD'] ||= dbconf['password'] if dbconf['password']
    ENV['PGHOST'] ||= dbconf['host'] || 'localhost'
    ENV['PGDATABASE'] ||= dbconf['database']
    ENV['PGUSER'] ||= dbconf['username'] || `whoami`.strip
  end

end
