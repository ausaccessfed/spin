require 'rails_helper'

RSpec.describe PermissionsController, type: :routing do
  let(:opts) { { role_id: '2' } }

  context 'get /admin/roles/:id/permissions' do
    subject { { get: '/admin/roles/2/permissions' } }
    it { is_expected.to route_to('permissions#index', opts) }
  end

  context 'post /admin/roles/:id/permissions' do
    subject { { post: '/admin/roles/2/permissions' } }
    it { is_expected.to route_to('permissions#create', opts) }
  end

  context 'delete /admin/roles/:id/permissions/:id' do
    subject { { delete: '/admin/roles/2/permissions/3' } }
    it { is_expected.to route_to('permissions#destroy', opts.merge(id: '3')) }
  end

  context 'get /admin/roles/:id/permissions/new' do
    subject { { get: '/admin/roles/2/permissions/new' } }
    it { is_expected.not_to be_routable }
  end

  context 'get /admin/roles/:id/permissions/:id/edit' do
    subject { { get: '/admin/roles/2/permissions/3/edit' } }
    it { is_expected.not_to be_routable }
  end

  context 'patch /admin/roles/:id/permissions/:id' do
    subject { { patch: '/admin/roles/2/permissions/3' } }
    it { is_expected.not_to be_routable }
  end
end
