RSpec.shared_examples 'an audited model' do
  subject { create(factory).reload }
  let(:factory) { described_class.name.underscore.to_sym }

  let(:base_attrs) do
    build(factory).attributes.symbolize_keys.except(:created_at,
                                                    :updated_at, :id)
  end

  let(:attrs) { base_attrs }

  it 'allows creation' do
    expect { described_class.create!(attrs) }
      .to not_raise_error
      .and change(described_class, :count).by(1)
  end

  context 'allows edit' do
    it 'without raising error' do
      expect { subject.update_attributes!(attrs) }.not_to raise_error
    end

    it 'provides supplied attributes' do
      subject.update_attributes!(attrs)
      expect(subject.reload).to have_attributes(attrs)
    end
  end

  it 'allows deletion' do
    obj = described_class.find(subject.id)

    expect { obj.destroy! }.to not_raise_error
      .and change(described_class, :count).by(-1)
  end
end
