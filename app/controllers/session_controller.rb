class SessionController < ApplicationController
  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    session[:logged_in_user_id] = @user.id
    redirect_to params[:redirect_to] || :root
  end

  def destroy
    session[:logged_in_user_id] = nil
    redirect_to params[:redirect_to] || :root
  end

  private
  def auth_hash
    request.env['omniauth.auth']
  end
end
