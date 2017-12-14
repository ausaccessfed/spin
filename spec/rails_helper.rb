ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

ActiveRecord::Migration.maintain_test_schema!

module ControllerMatchers
  extend RSpec::Matchers::DSL

  matcher :have_assigned do |sym, expected|
    include RSpec::Matchers::Composable
    match do |actual|
      actual.call if actual.is_a?(Proc)
      values_match?(expected, assigns[sym])
    end
    description { "set @#{sym} to #{description_of(expected)}" }
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include ControllerMatchers, type: :controller
  config.include DeleteButton, type: :feature, js: true
  config.include SanitizedMarkdownRenderer, type: :feature
  config.infer_spec_type_from_file_location!
  Capybara.javascript_driver = :webkit
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
