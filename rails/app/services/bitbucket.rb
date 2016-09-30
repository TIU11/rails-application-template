require 'colorize'

class Bitbucket
  # Expose class methods as instance methods
  extend Forwardable
  def_delegators self, :username, :password, :credentials, :owner, :repo_slug

  def self.username
    @@username ||= get_username
  end

  def self.password
    @@password ||= get_password
  end

  def self.credentials
    [username, password].join(':')
  end

  def self.owner
    @@owner ||= set_remote_info[0]
  end

  def self.repo_slug
    @@repo_slug ||= set_remote_info[1]
  end

  private

    def self.get_username
      # Test git connection and get username
      puts test_result = `ssh -T git@bitbucket.org`
      username = test_result[/logged in as (\w+)./, 1]
      if !username
        puts "Looks like you're not setup for Bitbucket yet".red
        puts "To troubleshoot, see https://confluence.atlassian.com/bitbucket/troubleshoot-ssh-issues-271943403.html".red
      end

      return username
    end

    # TODO: looks like prompting for a password can be replaced with newer options
    # @see (https://developer.atlassian.com/bitbucket/api/2/reference/meta/authentication)
    def self.get_password
      begin
        puts "What is your Bitbucket password?".cyan
        password = STDIN.noecho(&:gets).chomp
        raise ArgumentError if password.blank?
      rescue
        puts 'password cannot be empty'.red
        retry
      end
      password
    end

    # Read Bitbucket owner and repo_slug from git remote origin.
    # Look for remote origin that look like:
    # origin	https://georgeburdell@bitbucket.org/tiu/foo-bar.git (fetch)
    # origin	ssh://git@bitbucket.org/tiu/foo-bar.git (fetch)
    # origin	git@bitbucket.org:tiu/foo-bar.git (push)
    def self.set_remote_info
      remotes = `git remote -v`
      match = /origin\s+(\w+:\/\/)?\w+@bitbucket.org[\/:](\w+)\/([\w-]+).git/.match remotes
      @@owner = match && match[2]
      @@repo_slug = match && match[3]
      return @@owner, @@repo_slug
    end
end
