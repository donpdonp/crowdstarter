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

  def login
    user = User.find_by_email(params[:email])
    if user
      if BCrypt::Password.new(user.password_digest) == params[:password]
        session[:logged_in_user_id] = user.id
        render :json => {:status => "OK"}
      else
        render :json => {:status => "BADPASS"}
      end
    end
  end

  def destroy
    session[:logged_in_user_id] = nil
    redirect_to params[:redirect_to] || :root
  end

  def lookup
    user = User.find_by_email(params[:email])
    uson = {:email => params[:email]}
    if user
      uson.merge!({:status => "EXISTS"})
      if user.facebook_uid
        uson.merge!({:service => "facebook"})
        if !request.xhr?
          redirect_to "/auth/facebook"
          return
        end
      end
    else
      uson.merge!({:status => "MISSING"})
    end
    render :json => uson
  end

  private
  def auth_hash
    request.env['omniauth.auth']
  end
end
