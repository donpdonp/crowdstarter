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

  def edit
    @user = User.find(params[:id])
    unless @user == current_user
      flash[:error] = "No permissions to edit user #{@user.username}"
      redirect_to :root
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user == current_user
      @user.update_attributes(params[:user])
      if @user.valid?
        flash[:success] = "Profile updated!"
        redirect_to user_path(@user, :tab => "profile")
      else
        flash[:error] = "Update failed."
        redirect_to edit_user_path(@user)
      end
    else
      flash[:error] = "No permissions to edit user #{@user.username}"
      redirect_to :root
    end
  end
end
