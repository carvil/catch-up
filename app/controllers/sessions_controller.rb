class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    Session.create_with_uuid_and_name(params[:uuid], user.screen_name)
    redirect_to root_url
  end

  def destroy
    Session.find(params['uuid']).destroy!
    redirect_to root_url
  end

  def uuid
    render json: { uuid: UUIDTools::UUID.timestamp_create.to_s }
  end

  def current_twitter_user
    if screen_name = Session.find(params[:uuid]).try(:screen_name) and user = User.find(screen_name)
      render json: user.as_json
    else
      render :json => {:error => "not-found"}.to_json, :status => 404
    end
  end
end
