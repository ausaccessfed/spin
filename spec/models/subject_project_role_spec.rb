require 'rails_helper'

RSpec.describe SubjectProjectRole, type: :model do
  it_behaves_like 'an audited model'

  subject { create(:subject, :authorized).subject_project_roles.first! }

  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:project_role) }
end
