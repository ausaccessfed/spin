class SessionsController < ApplicationController
  def create
    # User has consented, time to authenticate...
    if (params['agree_to_consent'] == 'on')
      Rails.logger.info('User has consented, redirecting to rapid auth')
      env['rack.session'][:consent] = true
      redirect_to('/auth/login')
      return
    end

    # We only get here if js validation never occurred.
    Rails.logger.info('User has NOT consented, redirecting to root')
    redirect_to root_url
  end
end
