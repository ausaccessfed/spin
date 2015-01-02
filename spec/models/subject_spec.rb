require 'rails_helper'

RSpec.describe Subject, type: :model do
  it_behaves_like 'an audited model'

  subject { build(:subject, complete: false) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:mail) }
  it { is_expected.not_to validate_presence_of(:targeted_id) }
  it { is_expected.not_to validate_presence_of(:shared_token) }

  it 'contains no active projects' do
    expect(subject.active_project_count).to eq(0)
  end

  it 'contains no project roles' do
    expect(subject.distinct_project_roles).to eq([])
  end

  context 'with a complete subject' do
    subject { build(:subject, complete: true) }

    it { is_expected.to validate_presence_of(:targeted_id) }
    it { is_expected.to validate_presence_of(:shared_token) }
    it { is_expected.to validate_uniqueness_of(:shared_token) }
  end

  context 'with an authorized subject' do
    let(:authorized_subject) { create(:subject, :authorized) }

    it 'contains one active project' do
      expect(authorized_subject.active_project_count).to eq(1)
    end

    it 'contains one project role' do
      expect(authorized_subject.distinct_project_roles.count)
          .to eq(1)
      expect(authorized_subject.distinct_project_roles.first)
          .to be_a ProjectRole
    end
  end
end
