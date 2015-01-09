require 'rails_helper'

require 'gumboot/shared_examples/api_subjects'

RSpec.describe APISubject, type: :model do
  include_examples 'API Subjects'
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:api_subject) }

    it { is_expected.to validate_presence_of(:x509_cn) }
    it { is_expected.to validate_uniqueness_of(:x509_cn) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:contact_name) }
    it { is_expected.to validate_presence_of(:contact_mail) }

    it { is_expected.to allow_value('abcd').for(:x509_cn) }
    it { is_expected.not_to allow_value('abcd!').for(:x509_cn) }
    it { is_expected.not_to allow_value("abc\ndef").for(:x509_cn) }
  end

  context 'associated objects' do
    context 'api_subject_roles' do
      let(:child) { create(:api_subject_role) }
      subject { child.api_subject }
      it_behaves_like 'an association which cascades delete'
    end
  end

  context '#functioning?' do
    context 'when enabled' do
      subject { create(:api_subject, enabled: true) }
      it { is_expected.to be_functioning }
    end

    context 'when disabled' do
      subject { create(:api_subject, enabled: false) }
      it { is_expected.not_to be_functioning }
    end
  end

  context '#permits?' do
    let(:role) do
      create(:role).tap do |role|
        create(:permission, value: 'a:*', role: role)
      end
    end

    subject { create(:api_subject) }

    it 'derives permissions from roles' do
      subject.api_subject_roles.create(role_id: role.id)
      expect(subject.permits?('a:b:c')).to be_truthy
    end

    it 'only applies permissions from assigned roles' do
      role
      expect(subject.permits?('a:b:c')).to be_falsey
    end
  end
end
