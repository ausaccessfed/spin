require 'rails_helper'

module Authentication
  RSpec.describe SubjectReceiver do
    let(:env) { {} }

    context '#map_attributes' do
      let(:attrs) do
        keys = %w(edupersontargetedid auedupersonsharedtoken displayname mail)
        keys.reduce({}) { |a, e| a.merge(e => e) }
      end

      it 'maps the attributes' do
        expect(subject.map_attributes(env, attrs))
          .to eq(name: 'displayname',
                 mail: 'mail',
                 shared_token: 'auedupersonsharedtoken',
                 targeted_id: 'edupersontargetedid')
      end
    end

    context '#subject' do
      let(:attrs) do
        attributes_for(:subject)
      end

      it 'creates the subject' do
        expect { subject.subject(env, attrs) }.to change(Subject, :count).by(1)
      end

      it 'returns the new subject' do
        obj = subject.subject(env, attrs)
        expect(obj).to be_a(Subject)
        expect(obj).to have_attributes(attrs)
      end

      it 'updates an existing subject' do
        obj = subject.subject(env, attrs.merge(name: 'Wrong',
                                               mail: 'wrong@example.com'))
        subject.subject(env, attrs)
        expect(obj.reload).to have_attributes(attrs)
      end

      it 'returns the existing subject' do
        obj = subject.subject(env, attrs)
        expect(subject.subject(env, attrs)).to eq(obj)
      end

    end
  end
end
