module MiniAuth
  def current_user
    @current_user
  end

  def login(id)
    @current_user = User.find(id)
  end

  def logout
    @current_user = nil
  end

  def logged_in?
    !!@current_user
  end

  def auth
    id = session[:logged_in_user_id]
    if id
      login(id)
      logger.info("logging in from session: #{current_user}")
    end
  end
end
