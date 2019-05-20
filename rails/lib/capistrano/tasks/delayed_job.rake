# frozen_string_literal: true

namespace :delayed_job do
  desc "Force DelayedJob worker to stop, even if owned by another user."
  task :stop_with_sudo do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          status = capture :bundle, :exec, delayed_job_bin, delayed_job_args, :status, '2>&1', raise_on_non_zero_exit: false
          pid = /delayed_job: running \[pid (?<pid>\d+)\]/.match(status)&.named_captures&.dig('pid')

          if pid
            info "delayed_job: stopping process with pid #{pid}"
            execute :sudo, :kill, pid
          else
            info status
          end
        end
      end
    end
  end

  before 'delayed_job:restart', 'delayed_job:stop_with_sudo'
end
