class SessionController < ApplicationController
  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    if @user.valid?
      session[:logged_in_user_id] = @user.id
    else
      flash[:error] = "Sorry, there was a problem logging you in. #{@user.errors.full_messages}"
    end
    redirect_to params[:state] || :root
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
