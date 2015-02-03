require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context '#environment_string' do
    subject { helper.environment_string }
    it { is_expected.to eq('Development') }
  end

  context '#support_html' do
    subject { helper.support_html }
    let(:support_md) { Rails.root.join('config/support.md').read }
    let(:support_html) { Kramdown::Document.new(support_md).to_html }
    it { is_expected.to eq(support_html) }
  end
end
