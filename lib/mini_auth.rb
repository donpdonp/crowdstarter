module MiniAuth
  private
  def current_user
    @current_user
  end

  def log_in(id)
    @current_user = User.find(id)
  end

  def logout
    @current_user = nil
  end

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to root_path
    end
  end

  def logged_in?
    !!@current_user
  end

  def auth
    id = session[:logged_in_user_id]
    if id
      begin
        log_in(id)
        logger.info("session login: ##{current_user.id} #{current_user.username.inspect}")
      rescue ActiveRecord::RecordNotFound
        logger.info("session user id of #{id} is bogus. removing")
        session[:logged_in_user_id] = nil
        return false
      end
    end
  end
end
