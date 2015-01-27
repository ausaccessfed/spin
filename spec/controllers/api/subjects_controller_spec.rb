require 'rails_helper'

module API
  RSpec.describe SubjectsController, type: :controller do
    let(:api_subject) do
      role = create(:role)
      create(:permission, role: role, value: 'api')
      user = create(:api_subject, :authorized, permission: 'api:subjects:*')
      create(:api_subject_role, role: role, api_subject: user)
      user
    end

    before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}" }
    subject { response }

    context 'get :show' do
      before { get :show, format: 'json' }

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('api/subjects/show') }

      it 'assigns the subjects' do
        expect(assigns[:subjects]).to eq(Subject.all)
      end

      context 'as a non-privileged user' do
        let(:api_subject) { create(:api_subject) }

        it { is_expected.to have_http_status(:forbidden) }

        it 'responds with a message' do
          data = JSON.load(response.body)
          expect(data['message']).to match(/explicitly denied/)
        end
      end
    end
  end
end
