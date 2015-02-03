require 'rails_helper'

RSpec.describe RolesController, type: :routing do
  context 'get /admin/roles' do
    subject { { get: '/admin/roles' } }
    it { is_expected.to route_to('roles#index') }
  end

  context 'get /admin/roles/new' do
    subject { { get: '/admin/roles/new' } }
    it { is_expected.to route_to('roles#new') }
  end

  context 'post /admin/roles' do
    subject { { post: '/admin/roles' } }
    it { is_expected.to route_to('roles#create') }
  end

  context 'get /admin/roles/:id' do
    subject { { get: '/admin/roles/2' } }
    it { is_expected.to route_to('roles#show', id: '2') }
  end

  context 'get /admin/roles/edit' do
    subject { { get: '/admin/roles/2/edit' } }
    it { is_expected.to route_to('roles#edit', id: '2') }
  end

  context 'patch /admin/roles/:id' do
    subject { { patch: '/admin/roles/2' } }
    it { is_expected.to route_to('roles#update', id: '2') }
  end

  context 'delete /admin/roles/:id' do
    subject { { delete: '/admin/roles/2' } }
    it { is_expected.to route_to('roles#destroy', id: '2') }
  end
end
