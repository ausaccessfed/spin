require 'rails_helper'

RSpec.describe SubjectRolesController, type: :routing do
  let(:base) { {  role_id: '2' } }

  def action(name)
    "subject_roles##{name}"
  end

  context 'get /admin/roles/:id/members' do
    subject { { get: '/admin/roles/2/members' } }
    it { is_expected.not_to be_routable }
  end

  context 'get /admin/roles/:id/members/new' do
    subject { { get: '/admin/roles/2/members/new' } }
    it { is_expected.to route_to(action('new'), base) }
  end

  context 'post /admin/roles/:id/members' do
    subject { { post: '/admin/roles/2/members' } }
    it { is_expected.to route_to(action('create'), base) }
  end

  context 'get /admin/roles/:id/members/:id' do
    subject { { get: '/admin/roles/2/members/3' } }
    it { is_expected.not_to be_routable }
  end

  context 'patch /admin/roles/:id/members/:id' do
    subject { { patch: '/admin/roles/2/members/3' } }
    it { is_expected.not_to be_routable }
  end

  context 'delete /admin/roles/:id/members/:id' do
    subject { { delete: '/admin/roles/2/members/3' } }
    it { is_expected.to route_to(action('destroy'), base.merge(id: '3')) }
  end
end
