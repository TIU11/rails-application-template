# See https://github.com/railscasts/373-zero-downtime-deployment/blob/master/blog-after/config/recipes/base.rb

def template(from, to)
  require 'erb'
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end
