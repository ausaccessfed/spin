require 'rails_helper'

RSpec.describe SubjectProjectRole, type: :model do
  it_behaves_like 'an audited model'

  subject do
    create(:subject, :assigned_to_project)
      .subject_project_roles.first!
  end

  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:project_role) }

  it 'requires project role to be unique per subject' do
    other = build(:subject_project_role,
                  project_role: subject.project_role, subject: subject.subject)

    expect(other).not_to be_valid
  end
end
