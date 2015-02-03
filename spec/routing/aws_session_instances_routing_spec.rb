require 'rails_helper'

RSpec.describe AWSSessionInstancesController, type: :routing do
  context 'get /aws_login' do
    subject { { get: '/aws_login' } }
    it { is_expected.to route_to('aws_session_instances#auto') }
  end

  context 'post /aws_login' do
    subject { { post: '/aws_login' } }
    it { is_expected.to route_to('aws_session_instances#login') }
  end
end
