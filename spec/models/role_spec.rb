require 'rails_helper'

RSpec.describe Role, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:role) }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:aws_identifier) }
  end
end