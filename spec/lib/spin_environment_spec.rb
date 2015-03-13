require 'rails_helper'

RSpec.describe SpinEnvironment do
  describe '#environment_string' do
    subject { SpinEnvironment.environment_string }
    it { is_expected.to eq('Development') }
  end
  describe '#service_name' do
    subject { SpinEnvironment.service_name }
    it { is_expected.to eq('SPIN') }
  end
end
