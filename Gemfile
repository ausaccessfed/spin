source 'https://rubygems.org'
source 'https://rails-assets.org'

gem 'rails', '4.1.8'
gem 'sass-rails', '~> 4.0.3'
gem 'mysql2' # MySQL support
gem 'rapid-rack' # RapidConnect authenticator
gem 'accession' # Permissions for Ruby
gem 'rails-assets-semantic-ui', '~> 1.0' # Semantic UI web framework
gem 'rails-assets-jquery', '~> 1.11' # JQuery
gem 'unicorn', require: false # Web container

group :development, :test do
  gem 'spring',      '1.1.3'

  gem 'rspec-rails', '~> 3.1' # Testing framework
  gem 'factory_girl_rails' # Fixtures replacement
  gem 'faker' # Library for generating fake data

  gem 'pry', require: false # IRB alternative
  gem 'brakeman', '~> 2.6', require: false # Security scanner
  gem 'simplecov', require: false # Code coverage

  gem 'guard', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-brakeman', require: false
  gem 'guard-unicorn', require: false, ref: 'ca5177dd',
                       github: 'andreimaxim/guard-unicorn'
  gem 'terminal-notifier-guard', require: false
end
