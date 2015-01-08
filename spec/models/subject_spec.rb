require 'rails_helper'
require 'gumboot/shared_examples/subjects'

RSpec.describe Subject, type: :model do
  include_examples 'Subjects'
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:subject, complete: false) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:mail) }

    it { is_expected.not_to validate_presence_of(:targeted_id) }
    it { is_expected.not_to validate_presence_of(:shared_token) }

    it 'contains no active projects' do
      expect(subject.active_project_count).to eq(0)
    end

    it 'contains no project roles' do
      expect(subject.projects).to eq([])
    end

    context 'with a complete subject' do
      subject { build(:subject, complete: true) }

      it { is_expected.to validate_presence_of(:targeted_id) }
      it { is_expected.to validate_presence_of(:shared_token) }
      it { is_expected.to validate_uniqueness_of(:shared_token) }
    end
  end

  context 'assigned to project' do
    let(:authorized_subject) { create(:subject, :assigned_to_project) }

    it 'contains one active project' do
      expect(authorized_subject.active_project_count).to eq(1)
    end

    it 'contains one project role' do
      expect(authorized_subject.projects)
        .to contain_exactly(an_instance_of(Project))
    end
  end

  context '#functioning?' do
    context 'when enabled' do
      subject { create(:subject, enabled: true) }
      it { is_expected.to be_functioning }
    end

    context 'when disabled' do
      subject { create(:subject, enabled: false) }
      it { is_expected.not_to be_functioning }
    end
  end

  context '#permits?' do
    let(:role) do
      create(:role).tap do |role|
        create(:permission, value: 'a:*', role: role)
      end
    end

    subject { create(:subject) }

    it 'derives permissions from roles' do
      subject.subject_roles.create(role_id: role.id)
      expect(subject.permits?('a:b:c')).to be_truthy
    end

    it 'only applies permissions from assigned roles' do
      role
      expect(subject.permits?('a:b:c')).to be_falsey
    end
  end
end
