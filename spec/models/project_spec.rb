require 'rails_helper'

RSpec.describe Project, type: :model do
  it_behaves_like 'an audited model'

  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:provider_arn) }
  it { is_expected.to validate_presence_of(:state) }

  context '#provider_arn' do
    context 'saml-provider section' do
      let(:iam) { Faker::Number.number(10) }

      def provider_arn_string(saml_provider)
        "arn:aws:iam::1:saml-provider/#{saml_provider}"
      end

      it 'disallows 0 chars' do
        is_expected.to_not allow_value(provider_arn_string(
                                           '')).for(:provider_arn)
      end

      it 'allows alpha chars' do
        is_expected.to allow_value(provider_arn_string(
                                       Faker::Lorem.word))
          .for(:provider_arn)
      end

      it 'allows 128 chars' do
        is_expected.to allow_value(provider_arn_string(
                                       Faker::Lorem.characters(128)))
          .for(:provider_arn)
      end

      it 'allows alphanumeric chars' do
        is_expected.to allow_value(provider_arn_string(
                                       Faker::Lorem.characters(50)))
          .for(:provider_arn)
      end

      it 'allows \'-\', \'.\' and \'_\' chars' do
        is_expected.to allow_value(provider_arn_string('-._'))
          .for(:provider_arn)
      end

      it 'disallows 129 chars' do
        is_expected.to_not allow_value(provider_arn_string(
                                           Faker::Lorem.characters(129)))
          .for(:provider_arn)
      end

      it 'disallows other symbol chars' do
        is_expected.to_not allow_value(provider_arn_string(
                                           '~!@#$%^&*(')).for(:provider_arn)
      end
    end

    context 'iam section' do
      def provider_arn_string(iam)
        "arn:aws:iam::#{iam}:saml-provider/abc"
      end

      it 'disallows 0 chars' do
        is_expected.to_not allow_value(
                               provider_arn_string('')).for(:provider_arn)
      end

      it 'disallows alpha chars' do
        is_expected.to_not allow_value(provider_arn_string(Faker::Lorem.word))
          .for(:provider_arn)
      end

      it 'disallows symbol chars' do
        is_expected.to_not allow_value(provider_arn_string('._-~!@#$%^&*('))
          .for(:provider_arn)
      end

      it 'allows numeric chars' do
        is_expected.to allow_value(provider_arn_string(
                                           Faker::Number.number(10)))
          .for(:provider_arn)
      end
    end
  end

  context 'associated objects' do
    context 'project_roles' do
      let(:child) { create(:project_role) }
      subject { child.project }
      it_behaves_like 'an association which cascades delete'
    end
  end
end
