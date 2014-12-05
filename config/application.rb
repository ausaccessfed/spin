require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Spin
  class Application < Rails::Application
    config.autoload_paths << File.join(config.root, 'lib')
    config.rapid_rack.receiver = 'Authentication::SubjectReceiver'
    # config.rapid_rack.error_handler = 'MyApplication::MyErrorHandler'
  end
end
