require 'rails_helper'

RSpec.describe SpinEnvironment do
  let(:spin_cfg_hash) { YAML.load_file(
      Rails.root.join('config/spin_service.yml')) }
  let(:spin_cfg_os) { OpenStruct.new(spin_cfg_hash) }

  describe '#environment_string' do
    subject { SpinEnvironment.environment_string }
    it { is_expected.to eq(spin_cfg_os.environment_string) }
  end
  describe '#service_name' do
    subject { SpinEnvironment.service_name }
    it { is_expected.to eq(spin_cfg_os.service_name) }
  end
end
