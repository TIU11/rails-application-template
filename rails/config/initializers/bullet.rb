# Bullet reports N+1 queries and unused eager loading to the browser.
#
# Enable by adding `config.enable_bullet = true` to config/environments/development.rb
# Restricted to development since it loudly displays any findings.
if Rails.application.config.try(:enable_bullet)
  Rails.logger.error 'Need to install Bullet' # unless defined?(Bullet)
  Rails.application.config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
    # Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    # Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware', ['my_file.rb', 'my_method'], ['my_file.rb', 16..20] ]
    # Bullet.slack = { webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier' }

    # Override CSP to allow Bullet's inline script
    Rails.application.config.content_security_policy do |policy|
      policy.script_src :self, :https, :unsafe_inline if Bullet.enable?
    end
  end
end
