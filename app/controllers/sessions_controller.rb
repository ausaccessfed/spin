class SessionsController < ApplicationController

  def create
    Rails.logger.info("User log in attempted with params: #{params.inspect}")

    if (params["agree_to_consent"] == "1")
      redirect_to('/auth/login')
      return
    end

    # We only get here if js validation never occurred.
    redirect_to root_url
  end
end
