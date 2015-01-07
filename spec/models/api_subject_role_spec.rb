require 'rails_helper'

RSpec.describe APISubjectRole, :type => :model do
  it_behaves_like 'an audited model'

  subject { create(:api_subject_role) }

  it { is_expected.to validate_presence_of(:api_subject) }
  it { is_expected.to validate_presence_of(:role) }

  it 'requires role to be unique per api_subject' do
    other = build(:api_subject_role,
                  role: subject.role, api_subject: subject.api_subject)

    expect(other).not_to be_valid
  end

end
