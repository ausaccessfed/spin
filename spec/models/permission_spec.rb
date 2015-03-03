require 'rails_helper'

require 'gumboot/shared_examples/permissions'

RSpec.describe Permission, type: :model do
  include_examples 'Permissions'

  context 'validations' do
    subject { create(:permission) }
    it { is_expected.to validate_length_of(:value).is_at_most(255) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to allow_value('a').for(:value) }
    it { is_expected.to allow_value('a:b:c').for(:value) }
    it { is_expected.to allow_value('a:b:*').for(:value) }
    it { is_expected.to allow_value('a:*:c').for(:value) }
    it { is_expected.to allow_value('a:*:*').for(:value) }
    it { is_expected.to allow_value(Faker::Lorem.words.join(':')).for(:value) }
    it { is_expected.not_to allow_value('a:!b:c').for(:value) }
    it { is_expected.not_to allow_value('a:;b:c').for(:value) }
    it { is_expected.not_to allow_value("a:b\n:c").for(:value) }

    it 'requires permission with value to be unique per role' do
      other = build(:permission,
                    role: subject.role, value: subject.value)

      expect(other).not_to be_valid
    end
  end
end
