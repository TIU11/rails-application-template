namespace :deploy do
  namespace :check do

    desc "Check .env exists or initialize from .env.sample"
    task :initialize_dotenv do
      on roles(:web) do
        env_is_missing = !test("[ -f #{shared_path}/.env ]")
        if !env_is_missing
          info ".env already exists"
        elsif File.file?('.env.sample')
          content = StringIO.new(ERB.new(File.read('.env.sample')).result) # process template as ERB
          upload! content, "#{shared_path}/.env"
          info "Uploaded .env created from .env.sample"
        else
          info "'.env.sample' template not found"
        end
      end
    end

    before :linked_files, :initialize_dotenv

  end
end
