require 'rails_helper'

RSpec.describe AWSSessionInstancesController, type: :routing do
  context 'post /aws_login' do
    subject { { post: '/aws_login' } }
    it { is_expected.to route_to('aws_session_instances#create') }
  end
end
