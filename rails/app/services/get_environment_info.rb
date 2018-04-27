# frozen_string_literal: true

# Gather basic Environment Information, useful for determining state of multi-environment applications.
# Returns Info class, a singleton for performance.
class GetEnvironmentInfo

  DEPLOY_REVISION_PATH = 'REVISION'.freeze

  def initialize; end

  def self.call(*args)
    new.call(*args)
  end

  def call
    Info.instance # return Info singleton
  end

  class Info
    include Singleton

    # Rails environment name
    def name
      @name ||= Rails.env
    end

    # Git revision. For Capistrano deploys
    def revision
      @revision ||= begin
        if File.exist?(DEPLOY_REVISION_PATH)
          File.read(DEPLOY_REVISION_PATH).strip
        elsif git_repository?
          `git rev-parse HEAD`.strip
        end
      end
    end

    # True if application is in a git repository. False otherwise.
    def git_repository?
      @git ||= `git rev-parse --is-inside-work-tree 2> /dev/null`.strip == 'true'
    end

    # Get Time of current Capistrano release from application path, nil if not a timestamp.
    # Converts UTC timestamp to a local Time object.
    def released_at
      @released_at ||= begin
        # Note: We could be more precise by parsing the directory with strptime.
        # (https://github.com/capistrano/capistrano/blob/v3.9.0/lib/capistrano/dsl/env.rb#L34)
        # timestamp_format = "%Y%m%d%H%M%S"

        # Either developer's local project directory or Capistrano release directory:
        directory = Rails.root.basename

        # Capistrano :release_path is created using a UTC timestamp.
        # https://github.com/capistrano/capistrano/blob/v3.9.0/lib/capistrano/configuration.rb#L110
        directory.to_s.in_time_zone('UTC')&.localtime
      end
    rescue ArgumentError
      nil # return nil when directory name fails to parse to a time
    end

    def to_s
      "name: #{name}, git: #{git_repository?}, revision: #{revision}, released_at: #{released_at}"
    end
  end

end
