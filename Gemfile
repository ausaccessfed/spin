source 'https://rubygems.org'

gem 'rails', '4.1.8'
gem 'sass-rails', '~> 4.0.3'
gem 'jquery-rails'
gem 'uglifier', require: false
gem 'therubyracer', require: false
gem 'mysql2' # MySQL support
gem 'rapid-rack' # RapidConnect authenticator
gem 'accession',  '1.0.0'
gem 'aaf-lipstick', '1.1.0'

gem 'god', require: false
gem 'unicorn', require: false # Web container
gem 'redis'
gem 'redis-rails'
gem 'kramdown'
gem 'audited-activerecord'
gem 'jbuilder'
gem 'valhammer', '0.1.1'

gem 'coffee-rails'
gem 'smart_listing'

source 'https://rails-assets.org' do
  gem 'rails-assets-semantic-ui', '~> 1.11'
  gem 'rails-assets-jquery', '~> 1.11' # JQuery
end

group :development, :test do
  gem 'spring',      '1.1.3'

  gem 'rspec-rails', '~> 3.1.0' # Testing framework
  gem 'factory_girl_rails' # Fixtures replacement
  gem 'faker' # Library for generating fake data
  gem 'timecop'

  gem 'pry', require: false # IRB alternative
  gem 'pry-rails', require: false
  gem 'pry-byebug', require: false
  gem 'brakeman', '~> 2.6', require: false # Security scanner
  gem 'simplecov', require: false # Code coverage
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'sanitize'

  gem 'guard', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-brakeman', require: false
  gem 'guard-unicorn', require: false, ref: 'ca5177dd',
                       github: 'andreimaxim/guard-unicorn'
  gem 'terminal-notifier-guard', require: false
  gem 'aaf-gumboot', git: 'https://github.com/ausaccessfed/aaf-gumboot',
                     branch: 'develop'

  gem 'rest-client'
end
