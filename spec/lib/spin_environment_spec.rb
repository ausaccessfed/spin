require 'rails_helper'

RSpec.describe SpinEnvironment do
  context '#environment_string' do
    subject { SpinEnvironment.environment_string }
    it { is_expected.to eq('Development') }
  end
end
