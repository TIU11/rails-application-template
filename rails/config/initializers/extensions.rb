# Loads and applies extensions (monkey patches) from lib/extensions/.
# Also backports unreleased fixes.
#
# Resources:
# * https://stackoverflow.com/questions/17608006/how-to-reopen-a-class-in-gems
# * https://github.com/weppos/rubyist/blob/master/content/rails/extensions.md
# * https://www.justinweiss.com/articles/3-ways-to-monkey-patch-without-making-a-mess/

Dir[Rails.root.join('lib', 'extensions', '**', '*.rb')].each { |f| require f }

ActionView::Helpers::FormBuilder.include Extensions::ActionView::FormBuilderExtensions

ActiveSupport::Deprecation::DeprecatedConstantProxy.prepend ActiveSupportBackports

# PgSearch::Document.include PgSearchExtensions

# Process webp variants.
# See https://github.com/rails/rails/pull/38682
warn "[DEPRECATED] config no longer be needed. Please remove #{__FILE__}:#{__LINE__}!" if Rails.version >= '6.1'
Rails.application.config.active_storage.variable_content_types += %w[image/webp]
