require 'colorize'

class Bitbucket
  # Expose class methods as instance methods
  extend Forwardable
  def_delegators self, :username, :password, :credentials, :owner, :repo_slug

  class << self

    # Test git connection and get current user's username
    def username
      @username ||= begin
        if `ssh -T git@bitbucket.org` =~ /logged in as (\w+)./
          $1
        else
          puts <<~MSG.red
            Looks like you're not setup for Bitbucket yet
            To troubleshoot, see https://confluence.atlassian.com/bitbucket/troubleshoot-ssh-issues-271943403.html
          MSG
        end
      end
    end

    # TODO: looks like prompting for a password can be replaced with newer options
    # @see (https://developer.atlassian.com/bitbucket/api/2/reference/meta/authentication)
    def password
      @password ||= begin
        puts "What is your Bitbucket password?".cyan
        password = STDIN.noecho(&:gets).chomp
        raise ArgumentError if password.blank?
        password
      rescue StandardError
        puts 'password cannot be empty'.red
        retry
      end
    end

    def credentials
      [username, password].join(':')
    end

    def owner
      @owner || fetch_remote_info[0]
    end

    def repo_slug
      @repo_slug || fetch_remote_info[1]
    end

    private

      # Read Bitbucket owner and repo_slug from git remote origin.
      # Look for remote origin that look like:
      # origin	https://georgeburdell@bitbucket.org/tiu/foo-bar.git (fetch)
      # origin	ssh://git@bitbucket.org/tiu/foo-bar.git (fetch)
      # origin	git@bitbucket.org:tiu/foo-bar.git (push)
      def fetch_remote_info
        remotes = `git remote -v`
        match = %r{origin\s+(?:\w+://)?\w+@bitbucket.org[/:](\w+)/([\w-]+).git}.match remotes
        @owner, @repo_slug = match&.captures
      end
  end

end
