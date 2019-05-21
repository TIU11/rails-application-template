# frozen_string_literal: true

# For options, see https://voormedia.github.io/rails-erd/customise.html

namespace :erd do
  desc "Generate a standard ERD"
  task :standard do |_task|
    ENV['title'] = I18n.t 'app.title'
    ENV['exclude'] = 'PaperTrail::Version,PgSearch::Document,Delayed::Backend::ActiveRecord::Job'
    Rake::Task[:erd].invoke
  end

  desc "Generate a full ERD"
  task :full do |_task|
    ENV['title'] = I18n.t 'app.title'
    ENV['notation'] = 'bachman'
    ENV['polymorphism'] = 'true'
    Rake::Task[:erd].invoke
  end
end
