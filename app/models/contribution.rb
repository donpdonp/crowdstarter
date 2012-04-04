class Contribution < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  scope :successful, where(:status => "SC")

  #after_create :thank_the_user

  def successful?
    status == "SC"
  end

  def thank_the_user
    Notification.thanks(self)
  end
end
