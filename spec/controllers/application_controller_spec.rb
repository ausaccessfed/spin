require 'rails_helper'

require 'gumboot/shared_examples/application_controller'

RSpec.describe ApplicationController, type: :controller do
  include_examples 'Application controller' do
    # HACK: Disable the Gumboot examples which require Lipstick 3
    def render_template(*)
      be_an_instance_of(ActionController::TestResponse)
    end
  end
end
