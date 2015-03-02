require 'rails_helper'

RSpec.describe SubjectSession, type: :model do
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:remote_addr) }

  it { is_expected.to validate_length_of(:remote_host).is_at_most(255) }
  it { is_expected.to validate_length_of(:remote_addr).is_at_most(255) }
  it { is_expected.to validate_length_of(:http_user_agent).is_at_most(255) }
end
