require 'rails_helper'

RSpec.describe OrganisationsController, type: :routing do
  context 'get /admin/organisations' do
    subject { { get: '/admin/organisations' } }
    it { is_expected.to route_to('organisations#index') }
  end

  context 'get /admin/organisations/new' do
    subject { { get: '/admin/organisations/new' } }
    it { is_expected.to route_to('organisations#new') }
  end

  context 'post /admin/organisations' do
    subject { { post: '/admin/organisations' } }
    it { is_expected.to route_to('organisations#create') }
  end

  context 'get /admin/organisations/:id' do
    subject { { get: '/admin/organisations/2' } }
    it { is_expected.to route_to('organisations#show', id: '2') }
  end

  context 'get /admin/organisations/edit' do
    subject { { get: '/admin/organisations/2/edit' } }
    it { is_expected.to route_to('organisations#edit', id: '2') }
  end

  context 'patch /admin/organisations/:id' do
    subject { { patch: '/admin/organisations/2' } }
    it { is_expected.to route_to('organisations#update', id: '2') }
  end

  context 'delete /admin/organisations/:id' do
    subject { { delete: '/admin/organisations/2' } }
    it { is_expected.to route_to('organisations#destroy', id: '2') }
  end
end
