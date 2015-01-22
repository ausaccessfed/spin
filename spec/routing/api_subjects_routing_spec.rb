require 'rails_helper'

RSpec.describe APISubjectsController, type: :routing do
  def action(name)
    "api_subjects##{name}"
  end

  context 'get /admin/api_subjects' do
    subject { { get: '/admin/api_subjects' } }
    it { is_expected.to route_to(action('index')) }
  end

  context 'get /admin/api_subjects/:id' do
    subject { { get: '/admin/api_subjects/2' } }
    it { is_expected.to route_to(action('show'), id: '2') }
  end

  context 'get /admin/api_subjects/new' do
    subject { { get: '/admin/api_subjects/new' } }
    it { is_expected.to route_to(action('new')) }
  end

  context 'post /admin/api_subjects' do
    subject { { post: '/admin/api_subjects' } }
    it { is_expected.to route_to(action('create')) }
  end

  context 'get /admin/api_subjects/:id/edit' do
    subject { { get: '/admin/api_subjects/2/edit' } }
    it { is_expected.to route_to(action('edit'), id: '2') }
  end

  context 'patch /admin/api_subjects/:id' do
    subject { { patch: '/admin/api_subjects/2' } }
    it { is_expected.to route_to(action('update'), id: '2') }
  end

  context 'delete /admin/api_subjects/:id' do
    subject { { delete: '/admin/api_subjects/2' } }
    it { is_expected.to route_to(action('destroy'), id: '2') }
  end
end
