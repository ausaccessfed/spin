require 'rails_helper'

require 'gumboot/shared_examples/roles'

RSpec.describe Role, type: :model do
  include_examples 'Roles'
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:role) }

    it { is_expected.to validate_presence_of(:name) }
  end

  context 'associated objects' do
    context 'api_subject_roles' do
      let(:child) { create(:api_subject_role) }
      subject { child.role }
      it_behaves_like 'an association which cascades delete'
    end

    context 'subject_roles' do
      let(:child) { create(:subject_role) }
      subject { child.role }
      it_behaves_like 'an association which cascades delete'
    end

    context 'permissions' do
      let(:child) { create(:permission) }
      subject { child.role }
      it_behaves_like 'an association which cascades delete'
    end
  end
end
