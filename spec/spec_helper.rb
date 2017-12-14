require 'simplecov'

require 'factory_bot_rails'
require 'faker'
require 'mail'
require 'pry-rails'

Dir['./spec/support/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!

  config.order = :random
  Kernel.srand config.seed

  config.include FactoryBot::Syntax::Methods
  config.include Mail::Matchers

  RSpec::Matchers.define_negated_matcher :not_change, :change
  RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error
end
