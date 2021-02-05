# frozen_string_literal: true

# For options, see https://voormedia.github.io/rails-erd/customise.html

namespace :erd do
  desc "Generate a standard ERD"
  task standard: :environment do |_task|
    ENV['title'] = I18n.t 'app.title'
    ENV['exclude'] = 'PaperTrail::Version,PgSearch::Document,Delayed::Backend::ActiveRecord::Job'
    Rake::Task[:erd].invoke
  end

  desc "Generate a full ERD"
  task full: :environment do |_task|
    ENV['title'] = I18n.t 'app.title'
    ENV['notation'] = 'bachman'
    ENV['polymorphism'] = 'true'
    ENV['exclude'] = 'ApplicationRecord'
    Rake::Task[:erd].invoke
  end
end
