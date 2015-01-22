require 'rails_helper'

RSpec.describe ProjectRole, type: :model do
  it_behaves_like 'an audited model'

  it { is_expected.to validate_presence_of(:project) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:role_arn) }

  context 'associated objects' do
    context 'subject_project_roles' do
      let(:child) { create(:subject_project_role) }
      subject { child.project_role }
      it_behaves_like 'an association which cascades delete'
    end
  end

  context '#role_arn' do
    context 'saml-provider section' do
      let(:iam) { Faker::Number.number(10) }

      def role_arn_string(role)
        "arn:aws:iam::1:role/#{role}"
      end

      it 'disallows 0 chars' do
        is_expected.to_not allow_value(role_arn_string('')).for(:role_arn)
      end

      it 'allows alpha chars' do
        is_expected.to allow_value(role_arn_string(Faker::Lorem.word))
          .for(:role_arn)
      end

      it 'allows 64 alpha chars' do
        is_expected.to allow_value(role_arn_string(
                                       Faker::Lorem.characters(64)))
          .for(:role_arn)
      end

      it 'allows alphanumeric chars' do
        is_expected.to allow_value(role_arn_string(Faker::Lorem.characters(10)))
          .for(:role_arn)
      end

      it 'allows \'+\', \'=\', \',\', \'.\', \'@\', \'-\' and \'_\' chars' do
        is_expected.to allow_value(role_arn_string('+=,.@-_'))
          .for(:role_arn)
      end

      it 'disallows 65 chars' do
        is_expected.to_not allow_value(role_arn_string(
                                           Faker::Lorem.characters(65)))
          .for(:role_arn)
      end

      it 'disallows other symbol chars' do
        is_expected.to_not allow_value(role_arn_string(
                                           '~!@#$%^&*(')).for(:role_arn)
      end
    end

    context 'iam section' do
      def role_arn_string(iam)
        "arn:aws:iam::#{iam}:role/a"
      end

      it 'disallows 0 digits' do
        is_expected.to_not allow_value(role_arn_string('')).for(:role_arn)
      end

      it 'disallows alpha chars' do
        is_expected.to_not allow_value(role_arn_string(
                                           Faker::Lorem.word))
          .for(:role_arn)
      end

      it 'disallows symbol chars' do
        is_expected.to_not allow_value(role_arn_string('._-~!@#$%^&*('))
          .for(:role_arn)
      end

      it 'allows numeric chars' do
        is_expected.to allow_value(role_arn_string(
                                           Faker::Number.number(10)))
          .for(:role_arn)
      end
    end
  end
end
