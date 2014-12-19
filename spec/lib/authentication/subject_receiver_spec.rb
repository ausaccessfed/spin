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
      # TODO: Work in progress!
      # organisation = Organisation.create(name: "Test Org", external_id: "ID1")
      #
      # project = Project.create(name: "Test Proj 1", aws_account: "AWS_ACC1",
      #                           state: "A", organisation_id: organisation.id)
      #
      # subject = Subject.create(mail: "russell.ianniello@aaf.edu.au",
      #                           name: "Russell Ianniello",
      #                           targeted_id: "target_id")
      #
      # project_role = ProjectRole.create(name: "ALL for Test Proj 1",
      #                                    aws_identifier: "TP1",
      #                                    project_id: project.id)
      #
      # SubjectProjectRole.create(subject_id: subject.id,
      #                           project_role_id: project_role.id)

      # let(:env) do
      #   {'rack.session' => {'subject_id' => Subject.first}}
      # end
      #
      # it 'redirects to projects if subject has 0 projects' do
      #   expect(receiver.finish(env))
      #       .to eq([302, {'Location' => '/projects'}, []])
      # end
      #
      # it 'redirects to aws auth if subject has exactly 1 project' do
      #   expect(receiver.finish(env))
      #       .to eq([302, {'Location' => '/aws-idp'}, []])
      # end
      #
      # it 'redirects to projects if subject has > 1 projects' do
      #   expect(receiver.finish(env))
      #       .to eq([302, {'Location' => '/projects'}, []])
      # end
    end
  end
end
