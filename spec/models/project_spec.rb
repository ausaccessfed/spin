require 'rails_helper'

RSpec.describe Project, type: :model do
  it_behaves_like 'an audited model'

  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:provider_arn) }

  it { is_expected.to validate_length_of(:name).is_at_most(255) }
  it { is_expected.to validate_length_of(:provider_arn).is_at_most(255) }

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

    context 'with whitespace' do
      let(:provider_arn) { 'arn:aws:iam::1:saml-provider/1' }

      context 'preceding' do
        let(:provider_arn_preceding_whitespace) { ' ' + provider_arn }
        it 'is allowed' do
          is_expected.to allow_value(provider_arn_preceding_whitespace)
            .for(:provider_arn)
        end

        context 'when persisting' do
          subject do
            create(:project,
                   provider_arn: provider_arn_preceding_whitespace)
          end
          it 'trims the whitespace' do
            expect(subject.provider_arn).to eq(provider_arn)
          end
        end
      end

      context 'trailing' do
        let(:provider_arn_trailing_whitespace) { provider_arn + ' ' }

        it 'is allowed' do
          is_expected.to allow_value(provider_arn_trailing_whitespace)
            .for(:provider_arn)
        end

        context 'when persisting' do
          subject do
            create(:project,
                   provider_arn: provider_arn_trailing_whitespace)
          end
          it 'trims the whitespace' do
            expect(subject.provider_arn).to eq(provider_arn)
          end
        end
      end
    end
  end

  context '::filter' do
    let(:project) { create(:project, name: 'Test Project') }
    subject { Project.filter(search) }

    shared_context 'a match' do
      it 'includes the project' do
        expect(subject).to include(project)
      end
    end

    shared_context 'a nonmatch' do
      it 'excludes the project' do
        expect(subject).not_to include(project)
      end
    end

    context 'prefix' do
      let(:search) { 'Test' }
      include_context 'a match'
    end

    context 'substring' do
      let(:search) { 'Proj' }
      include_context 'a match'
    end

    context 'multiword match' do
      let(:search) { 'Project Test' }
      include_context 'a match'
    end

    context 'nonmatch' do
      let(:search) { 'Flarghn' }
      include_context 'a nonmatch'
    end

    context 'nonmatch' do
      let(:search) { 'Test Flarghn' }
      include_context 'a nonmatch'
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
