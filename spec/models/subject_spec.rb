require 'rails_helper'

RSpec.describe Subject, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:subject, complete: false) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:mail) }
    it { is_expected.not_to validate_presence_of(:targeted_id) }
    it { is_expected.not_to validate_presence_of(:shared_token) }

    context 'with a complete subject' do
      subject { build(:subject, complete: true) }

      it { is_expected.to validate_presence_of(:targeted_id) }
      it { is_expected.to validate_presence_of(:shared_token) }
      it { is_expected.to validate_uniqueness_of(:shared_token) }
    end
  end

end
