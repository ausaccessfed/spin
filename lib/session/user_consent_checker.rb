module Session
  class UserConsentChecker
    def initialize(app)
      @app = app
    end

    def call(env)
      if env['REQUEST_PATH'] == '/auth/login'
        unless env['rack.session'] && env['rack.session']['consent']
          Rails.logger.info('Request sent to /auth/login without consent!')
          return [301, { 'Location' => '/', 'Content-Type' => 'text/html' }, []]
        end
      end
      @app.call(env)
    end
  end
end
