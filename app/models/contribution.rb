class Contribution < ActiveRecord::Base
  include Workflow

  belongs_to :project
  belongs_to :user

  scope :successful, where(:status => "SC")

  #after_create :thank_the_user
  workflow do
    state :incomplete do
      event :approve, :transitions_to => :authorized
    end
    state :authorized do
      event :collect, :transitions_to => :collected
    end
    state :collected
  end

  def successful?
    status == "SC"
  end

  def thank_the_user
    Notification.thanks(self)
  end
end
