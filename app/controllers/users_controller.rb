class UsersController < ApplicationController
  def create
    if params[:password].blank?
      render :json => {:status => "BADPASS"}
      return
    end

    user = User.create(:email => params[:email],
                       :username => params[:username],
                       :password_digest => BCrypt::Password.create(params[:password]))
    if user.valid?
      # login
      session[:logged_in_user_id] = user.id
      flash[:success] = "Your account has been created!"
      ret = {:status => "OK"}
    else
      ret = {:status => "ERR", :errors => user.errors.to_json}
    end
    render :json => ret
  end

  def show
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :root
    end
  end
end
