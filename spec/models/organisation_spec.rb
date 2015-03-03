require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it_behaves_like 'an audited model'

  subject { create(:organisation) }

  it { is_expected.to validate_presence_of(:unique_identifier) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(255) }
  it { is_expected.to validate_length_of(:unique_identifier).is_at_most(255) }

  it { is_expected.to validate_uniqueness_of(:unique_identifier) }

  context 'associated objects' do
    context 'projects' do
      let(:child) { create(:project) }
      subject { child.organisation }
      it_behaves_like 'an association which cascades delete'
    end
  end
end
