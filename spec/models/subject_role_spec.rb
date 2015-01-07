require 'rails_helper'

RSpec.describe SubjectRole, type: :model do
  it_behaves_like 'an audited model'

  subject { create(:subject, :admin).subject_roles.first! }

  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:role) }

  it 'requires role to be unique per subject' do
    other = build(:subject_role,
                  role: subject.role, subject: subject.subject)

    expect(other).not_to be_valid
  end
end
