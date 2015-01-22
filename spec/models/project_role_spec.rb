require 'rails_helper'

RSpec.describe ProjectRole, type: :model do
  it_behaves_like 'an audited model'

  it { is_expected.to validate_presence_of(:project) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:aws_identifier) }

  context 'associated objects' do
    context 'subject_project_roles' do
      let(:child) { create(:subject_project_role) }
      subject { child.project_role }
      it_behaves_like 'an association which cascades delete'
    end
  end
end
