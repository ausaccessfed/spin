class SpinEnvironment
  def self.environment_string
    Rails.application.config.spin_service.environment_string
  end
end
