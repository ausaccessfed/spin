require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:organisation) }

    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:name) }
  end

end
