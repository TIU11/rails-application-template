namespace :deploy do

  namespace :check do

    desc "Initialize missing .env from .env.sample"
    task :initialize_dotenv do
      on roles(:web) do
        env_is_missing = !test("[ -f #{shared_path}/.env ]")
        if env_is_missing and File.exist?('.env.sample')
          upload! '.env.sample', "#{shared_path}/.env"
        end
      end
    end
    before :linked_files, :initialize_dotenv

  end

end
