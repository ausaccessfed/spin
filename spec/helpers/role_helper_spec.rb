require 'rails_helper'

RSpec.describe RolesHelper, type: :helper do
  let(:role) { create(:role) }

  context '#member_count' do
    subject { (member_count(role)) }

    context 'with no children' do
      it { is_expected.to eq(0) }
    end

    context 'with 1 child' do
      let(:child) { create(:api_subject_role) }
      subject { (member_count(child.role)) }
      it { is_expected.to eq(1) }
    end

    context 'with multiple children' do
      before { create(:subject_role, role_id: role.id) }
      before { create(:api_subject_role, role_id: role.id) }
      before { create(:api_subject_role, role_id: role.id) }
      subject { (member_count(role)) }
      it { is_expected.to eq(3) }
    end
  end

end
