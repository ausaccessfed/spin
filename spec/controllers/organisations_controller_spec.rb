require 'rails_helper'

RSpec.describe OrganisationsController, type: :controller do
  let(:user) do
    create(:subject, :authorized,
           permission: 'admin:organisations:*')
  end

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :show' do
    let(:organisation) { create(:organisation) }

    before { get :show, id: organisation.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('organisations/show') }
    it { is_expected.to have_assigned(:organisation, organisation) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end
  end

  context 'patch :update' do
    let!(:organisation) { create(:organisation) }

    before do
      patch :update, id: organisation.id,
                     organisation: attributes_for(:organisation)
    end

    it { is_expected.to redirect_to(organisations_path) }
    it { is_expected.to have_assigned(:organisation, organisation) }

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with invalid attributes' do
      before do
        patch :update, id: organisation.id,
                       organisation: attributes_for(:organisation, name: nil)
      end

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('organisations/edit') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to save Organisation\n\nName can't be blank")
      end
    end
  end

  context 'post :destroy' do
    let!(:organisation) { create(:organisation) }

    def run
      delete :destroy, id: organisation.id
    end

    subject { -> { run } }

    it { is_expected.to change(Organisation, :count).by(-1) }
    it { is_expected.to have_assigned(:organisation, organisation) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(organisations_path) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Organisation, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    context 'with no user' do
      let(:user) {}
      it { is_expected.not_to change(Organisation, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:redirect) }
      end
    end
  end

  context 'get :edit' do
    let!(:organisation) { create(:organisation) }
    before { get :edit, id: organisation.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('organisations/edit') }
    it { is_expected.to have_assigned(:organisation, organisation) }

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :create' do
    before { post :create, organisation: attributes_for(:organisation) }
    it { is_expected.to have_http_status(:redirect) }
    it { is_expected.to have_assigned(:organisation, be_a(Organisation)) }

    it 'sets the flash message' do
      expect(flash[:success])
        .to eq("Created new Organisation: #{Organisation.last.name}")
    end

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with invalid attributes' do
      before do
        post :create, organisation: attributes_for(:organisation,
                                                   name: nil)
      end

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('new') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to create Organisation\n\nName can't be blank")
      end
    end
  end

  context 'get :new' do
    before { get :new }
    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('organisations/new') }
    it { is_expected.to have_assigned(:organisation, be_a_new(Organisation)) }

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'get :index' do
    before { get :index }
    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('organisations/index') }
    it { is_expected.to have_assigned(:organisations, Organisation.all) }

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end
end
