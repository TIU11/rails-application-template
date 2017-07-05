# Generators defaults
# @see (http://guides.rubyonrails.org/generators.html#customizing-your-workflow)
Rails.application.config.generators do |g|
  # Hack to override Rails' Erb::Generators::ScaffoldGenerator
  g.template_engine :all # Defaults to :erb
  g.fallbacks[:all] = :erb

  # Don't generate default scaffolds.scss
  g.scaffold_stylesheet false

  #
  # Tests
  #

  g.fixture_replacement :factory_girl # Test data

  # We always start with unit tests and feature (end-to-end) tests. Other tests are added as needed.

  # Skip controller and view specs. See Rails 4 Test Prescriptions, p.138 "Testing Controllers and Views"
  g.controller_specs false # create when verifying security, handling of invalid requests, etc.
  g.view_specs false

  # Skip request and routing specs. See Rails 4 Test Prescriptions, p.143 "Testing Routes"
  # Add these when doing something complicated with the routes
  g.request_specs false
  g.routing_specs false
end
