require 'rails_helper'

RSpec.describe AWSSessionInstance, type: :model do
  delegate :urlsafe_base64, to: SecureRandom

  context 'validations' do
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:project_role) }
    it { is_expected.to validate_presence_of(:identifier) }

    it { is_expected.to allow_value('a' * 40).for(:identifier) }
    it { is_expected.to allow_value('_' * 40).for(:identifier) }
    it { is_expected.to allow_value('-' * 40).for(:identifier) }
    it { is_expected.to allow_value(urlsafe_base64(30)).for(:identifier) }
    it { is_expected.not_to allow_value('a' * 39).for(:identifier) }
    it { is_expected.not_to allow_value('!a' * 20).for(:identifier) }
  end

  context 'after_initialize' do
    let(:attrs) do
      { subject: create(:subject), project_role: create(:project_role) }
    end

    subject { AWSSessionInstance.new.tap { |o| o.attributes = attrs } }
    it { is_expected.to have_attributes(identifier: anything) }
    it { is_expected.to be_valid }

    it 'returns the same value when loaded' do
      subject.save!
      expect(subject.identifier).to eq(subject.reload.identifier)
    end
  end
end
