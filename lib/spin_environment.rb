class SpinEnvironment
  def self.environment_string
    Rails.application.config.spin_service.environment_string
  end

  def self.service_name
    Rails.application.config.spin_service.service_name
  end
end
