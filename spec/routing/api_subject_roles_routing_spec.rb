require 'rails_helper'

RSpec.describe APISubjectRolesController, type: :routing do
  let(:base) { { role_id: '2' } }

  def action(name)
    "api_subject_roles##{name}"
  end

  context 'get /admin/roles/:id/api_members' do
    subject { { get: '/admin/roles/2/api_members' } }
    it { is_expected.not_to be_routable }
  end

  context 'get /admin/roles/:id/api_members/new' do
    subject { { get: '/admin/roles/2/api_members/new' } }
    it { is_expected.to route_to(action('new'), base) }
  end

  context 'post /admin/roles/:id/api_members' do
    subject { { post: '/admin/roles/2/api_members' } }
    it { is_expected.to route_to(action('create'), base) }
  end

  context 'get /admin/roles/:id/api_members/:id' do
    subject { { get: '/admin/roles/2/api_members/3' } }
    it { is_expected.not_to be_routable }
  end

  context 'patch /admin/roles/:id/api_members/:id' do
    subject { { patch: '/admin/roles/2/api_members/3' } }
    it { is_expected.not_to be_routable }
  end

  context 'delete /admin/roles/:id/api_members/:id' do
    subject { { delete: '/admin/roles/2/api_members/3' } }
    it { is_expected.to route_to(action('destroy'), base.merge(id: '3')) }
  end
end
