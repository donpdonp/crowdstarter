class Contribution < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  after_create :thank_the_user

  def successful?
    status == "SC"
  end

  def thank_the_user
    Notifications.thanks(self)
  end
end
