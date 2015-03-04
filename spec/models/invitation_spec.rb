require 'rails_helper'

RSpec.describe Invitation, type: :model do
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:invitation) }

    it { is_expected.to validate_presence_of(:subject) }

    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_uniqueness_of(:identifier) }
    it { is_expected.to validate_length_of(:identifier).is_at_most(255) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }

    it { is_expected.to validate_presence_of(:mail) }
    it { is_expected.to validate_uniqueness_of(:mail) }
    it { is_expected.to validate_length_of(:mail).is_at_most(255) }

    it { is_expected.to validate_presence_of(:expires) }

    it { is_expected.to allow_value('abcdefg1234').for(:identifier) }
    it { is_expected.not_to allow_value('abc!').for(:identifier) }
    it { is_expected.not_to allow_value("abc\ndef").for(:identifier) }
  end

  context 'default values' do
    subject { create(:invitation) }
    it 'sets used to default value' do
      expect(subject.used).to be_falsey
    end
  end
end
