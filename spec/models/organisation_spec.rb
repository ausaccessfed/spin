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

  context '::filter' do
    let(:organisation) do
      create(:organisation, name: 'Test Organisation',
                            unique_identifier: 'omg_its_an_organisation')
    end

    subject { Organisation.filter(search) }

    shared_context 'a match' do
      it 'includes the organisation' do
        expect(subject).to include(organisation)
      end
    end

    shared_context 'a nonmatch' do
      it 'excludes the organisation' do
        expect(subject).not_to include(organisation)
      end
    end

    context 'name prefix' do
      let(:search) { 'Test' }
      include_context 'a match'
    end

    context 'name substring' do
      let(:search) { 'Org' }
      include_context 'a match'
    end

    context 'identifier prefix' do
      let(:search) { 'omg_it' }
      include_context 'a match'
    end

    context 'identifier substring' do
      let(:search) { 'ts_an_or' }
      include_context 'a match'
    end

    context 'multiword name match' do
      let(:search) { 'Organisation Test' }
      include_context 'a match'
    end

    context 'multiword multifield match' do
      let(:search) { 'omg_its_a Test' }
      include_context 'a match'
    end

    context 'nonmatch' do
      let(:search) { 'Flarghn' }
      include_context 'a nonmatch'
    end

    context 'multiword nonmatch' do
      let(:search) { 'Test Flarghn' }
      include_context 'a nonmatch'
    end
  end
end
