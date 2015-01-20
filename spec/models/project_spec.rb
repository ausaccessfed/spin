require 'rails_helper'

RSpec.describe Project, type: :model do
  it_behaves_like 'an audited model'

  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:provider_arn) }
  it { is_expected.to validate_presence_of(:state) }

  context 'associated objects' do
    context 'project_roles' do
      let(:child) { create(:project_role) }
      subject { child.project }
      it_behaves_like 'an association which cascades delete'
    end
  end
end
