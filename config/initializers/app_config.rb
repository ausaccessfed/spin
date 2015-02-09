Rails.application.configure do
  spin_config = YAML.load_file(Rails.root.join('config/spin_service.yml'))
  config.spin_service = OpenStruct.new(spin_config)
end
