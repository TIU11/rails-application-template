# Loads and applies extensions (monkey patches) from lib/extensions/.
# Also backports unreleased fixes.
#
# Resources:
# * https://stackoverflow.com/questions/17608006/how-to-reopen-a-class-in-gems
# * https://github.com/weppos/rubyist/blob/master/content/rails/extensions.md
# * https://www.justinweiss.com/articles/3-ways-to-monkey-patch-without-making-a-mess/

Dir[Rails.root.join('lib/extensions/**/*.rb')].sort.each { |f| require f }

ActionView::Helpers::FormBuilder.include Extensions::ActionView::FormBuilderExtensions

# PgSearch::Document.include PgSearchExtensions
