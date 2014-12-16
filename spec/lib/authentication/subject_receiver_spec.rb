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
  end
end
