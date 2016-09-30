require 'colorize'

namespace :app do
  desc "Check .env exists or initialize from .env.sample"
  task :create_dotenv do
    if File.file?('.env')
      puts ".env already exists".cyan
      next
    elsif File.file?('.env.sample')
      File.open('.env', 'w') do |f|
        erb = ERB.new(File.read('.env.sample'), nil, '>')
        f.write erb.result # process template as ERB
      end
      puts ".env created from .env.sample".cyan
    else
      abort "'.env.sample' template not found"
    end
  end
end
