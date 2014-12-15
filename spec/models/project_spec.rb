require 'rails_helper'

RSpec.describe Project, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:project) }

    it { is_expected.to validate_presence_of(:organisation) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:aws_account) }
    it { is_expected.to validate_presence_of(:state) }
  end
end
