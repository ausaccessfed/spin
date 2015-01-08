require 'rails_helper'

require 'gumboot/shared_examples/application_controller'

RSpec.describe ApplicationController, type: :controller do
  include_examples 'Application controller'

  before { session[:subject_id] = user.id }
  let(:user) { create(:subject, :authorized, permission: 'permit') }

end
