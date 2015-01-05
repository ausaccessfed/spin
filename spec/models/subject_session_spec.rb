require 'rails_helper'

RSpec.describe SubjectSession, type: :model do
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:remote_addr) }
end
