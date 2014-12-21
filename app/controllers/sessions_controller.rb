class SessionsController < ApplicationController
  def create
    # User has consented, time to authenticate...
    if (params['agree_to_consent'] == 'on')
      set_user_consent
      return redirect_to('/auth/login')
    end

    # We only get here if js validation never occurred.
    Rails.logger.info('User has NOT consented, redirecting to root')
    redirect_to root_url
  end

  def set_user_consent
    Rails.logger.info('User has consented, setting in rack session')
    env['rack.session'][:consent] = true if env['rack.session']
  end
end
