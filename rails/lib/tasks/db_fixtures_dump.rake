# frozen_string_literal: true

# Create fixtures from existing db records
#
# Inspired by:
# * https://gist.github.com/iiska/1527911/ede9d84e15b0f7b079693ab98b65a1beb319a2ab
# * https://gist.github.com/kuboon/55d4d8e862362d30456e7aa7cd6c9cf5
# * https://gist.github.com/existentialmutt/a36d024b0ca7bbf5d3e81fa8b2cd692d

namespace 'db:fixtures' do
  EXCLUDED_ATTRIBUTES = %w[created_at updated_at].freeze

  desc 'Dumps database into fixtures. Specify a model for just one.'
  task :dump, [:model] => :environment do |_task, args|
    models = if args.model
               klass = args.model.classify.constantize
               [klass] if klass.ancestors.include? ActiveRecord::Base
             else
               Rails.application.eager_load!
               ActiveRecord::Base.descendants
             end

    # justify name by the longest
    max_width = models.map { |m| m.name.underscore }.max_by(&:length).length

    models.each do |model|
      next unless model.table_exists?

      # PaperTrail::Version => test/fixtures/paper_trail/version.yml
      path = Rails.root.join('test/fixtures', "#{model.table_name}.yml")
      FileUtils.mkdir_p path.dirname

      puts model.to_s.ljust(max_width)
      puts "\t=> #{path}"

      path.open('w') do |file|
        hash = {}
        model.find_each do |r|
          key = r.try(:name) || "#{path.basename('.*')}_#{r.id}"
          hash[key] = r.attributes.except(*EXCLUDED_ATTRIBUTES)
        end
        file.write hash.to_yaml
      end

      spec_path = Rails.root.join('spec/fixtures', "#{model.table_name}.yml")
      FileUtils.mkdir_p spec_path.dirname
      FileUtils.cp path, spec_path

      puts "\t=> #{spec_path}"
    end
  end
end
