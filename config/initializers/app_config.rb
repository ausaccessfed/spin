require 'mail'

Rails.application.configure do
  spin_config = YAML.load_file(Rails.root.join('config/spin_service.yml'))
  config.spin_service = OpenStruct.new(spin_config)

  config.spin_service = OpenStruct.new(spin_config).tap do |c|
    c.mail.symbolize_keys!
  end

  mail_config = config.spin_service.mail
  Mail.defaults { delivery_method :smtp, mail_config }

  if Rails.env.test?
    config.spin_service.mail = OpenStruct.new(from: 'noreply@example.com')
    config.spin_service.provider_prefix = 'urn:x-aaf:dev:spin:rspec'
    Mail.defaults { delivery_method :test }
  end
end
