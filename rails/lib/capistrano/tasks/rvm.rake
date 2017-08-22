namespace :rvm do

  # Bypass rvm:check when user directly invokes any rvm namespace tasks, except rvm:check itself.
  task :bypass_check do |task, _args|
    tasks_in_namespace = Rake.application.tasks.select { |t| t.scope == task.scope }.map(&:name)
    trigger_tasks = tasks_in_namespace - ['rvm:check']

    if (trigger_tasks & Rake.application.top_level_tasks).any? # user invoked a task that triggers the bypass
      Rake::Task['rvm:check'].clear_actions
      run_locally do
        execute :echo, "Dropping 'rvm:check' when running '#{ARGV.last}'"
      end
    end
  end
  before :hook, :bypass_check

  desc "Install project's ruby with rvm"
  task :install_ruby do
    on roles(:web) do
      ruby_version = fetch(:rvm_ruby_version).split('@').first
      installed_rubies = capture :rvm, 'list strings'

      if installed_rubies.include? ruby_version
        execute :echo, "#{ruby_version} already installed"
      else
        execute :rvm, "install #{ruby_version}"
        execute :rvm, "#{ruby_version}@global do gem install bundler"
      end
    end
  end

  desc "Create project's gemset with rvm"
  task :create_gemset => :install_ruby do
    on roles(:web) do
      ruby_version, gemset = fetch(:rvm_ruby_version).split('@')
      execute :rvm, "#{ruby_version} do rvm gemset create #{gemset}"
    end
  end
end
