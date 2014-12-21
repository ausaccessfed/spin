require 'rails_helper'

module Authentication
  RSpec.describe SubjectReceiver do
    subject(:receiver) { SubjectReceiver.new }
    let(:env) { {} }

    context '#map_attributes' do
      let(:attrs) do
        keys = %w(edupersontargetedid auedupersonsharedtoken displayname mail)
        keys.reduce({}) { |a, e| a.merge(e => e) }
      end

      it 'maps the attributes' do
        expect(receiver.map_attributes(env, attrs))
          .to eq(name: 'displayname',
                 mail: 'mail',
                 shared_token: 'auedupersonsharedtoken',
                 targeted_id: 'edupersontargetedid')
      end
    end

    context '#subject' do
      let(:attributes) do
        attributes_for(:subject)
      end
      let(:updated_attributes) do
        attributes.merge(name: Faker::Name.name,
                         mail: Faker::Internet.email)
      end

      context 'without an existing Subject' do
        subject { receiver.subject(env, attributes) }

        it 'stores a new Subject' do
          expect { receiver.subject(env, attributes) }
            .to change(Subject, :count).by(1)
        end

        it { is_expected.to be_a(Subject) }
        it { is_expected.to have_attributes(attributes) }
      end

      context 'with an existing Subject' do
        let!(:created_subject) { receiver.subject(env, attributes) }
        subject { receiver.subject(env, updated_attributes).reload }

        it { is_expected.to eq(created_subject) }
        it { is_expected.to have_attributes(updated_attributes) }
      end
    end

    context 'after authenticating with idP' do
      let(:Subject) { double }
      let(:subject_for_session) { double }
      let(:project_roles) { double }
      let(:select_projects_association) { double }

      before do
        allow(Subject)
          .to receive(:find)
          .and_return(subject_for_session)
      end

      before do
        allow(subject_for_session)
          .to receive(:project_roles)
          .and_return(project_roles)
      end

      before do
        allow(project_roles)
          .to receive(:select)
          .and_return(select_projects_association)
      end

      let(:env) do
        { 'rack.session' => { 'subject_id' => 1 } }
      end

      context 'with no projects' do
        before do
          allow(select_projects_association)
            .to receive(:distinct)
            .and_return({})
        end

        it 'redirects to no projects assigned page' do
          expect(receiver.finish(env))
            .to eq([302, { 'Location' => '/no_projects_assigned' }, []])
        end
      end

      context 'with exactly 1 project' do
        let(:projects) { [create(:project)] }

        before do
          allow(select_projects_association)
            .to receive(:distinct)
            .and_return(projects)
        end

        it 'redirects to aws auth' do
          expect(receiver.finish(env))
            .to eq([302, { 'Location' => '/aws-idp' }, []])
        end
      end

      context 'with more than 1 project' do
        let(:projects) { Array.new(3) { create(:project) } }

        before do
          allow(select_projects_association)
            .to receive(:distinct)
            .and_return(projects)
        end

        it 'redirects to projects page' do
          expect(receiver.finish(env))
            .to eq([302, { 'Location' => '/projects' }, []])
        end
      end
    end
  end
end
