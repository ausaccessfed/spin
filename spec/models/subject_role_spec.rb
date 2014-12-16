require 'rails_helper'

RSpec.describe SubjectRole, type: :model do
  it_behaves_like 'an audited model'

  subject { create(:subject, :authorized).subject_roles.first! }

  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:role) }
end
