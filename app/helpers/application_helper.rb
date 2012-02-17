module ApplicationHelper
  def user_link(user)
    link_to user.email, user
  end
end
