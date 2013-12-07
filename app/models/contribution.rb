class Contribution < ActiveRecord::Base
  include Workflow
  include Wepay

  belongs_to :project
  belongs_to :user
  belongs_to :reward
  belongs_to :gateway

  has_many :gateway_logs

  validates :amount, :numericality => true
  validates :project_id, :gateway_id, :presence => true

  scope :authorizeds, where(:workflow_state => :authorized)
  scope :reserveds, where(:workflow_state => :reserved)
  scope :captureds, where(:workflow_state => :captured)
  scope :cancelleds, where(:workflow_state => :cancelled)

  workflow do
    state :new do
      event :authorize, :transitions_to => :authorized
    end
    state :authorized do
      event :reserve, :transitions_to => :reserved
      event :cancel, :transitions_to => :cancelled
    end
    state :reserved do
      event :capture, :transitions_to => :captured
      event :cancel, :transitions_to => :cancelled
    end
    state :captured do
      event :settle, :transitions_to => :settled
      event :refund, :transitions_to => :refunded
    end
    state :refunded
    state :settled
    state :cancelled
  end

  # workflow transition handlers
  def capture
  end

  def authorize
    Activity.create({:detail => "Contributed $#{self.amount}",
                     :code => "contributed",
                     :contribution => self,
                     :user => self.user,
                     :project => self.project})
    Notifications.delay(:queue => 'mailer').contribution_thanks(self)
  end

  def cancel
  end

  # helpers
  def reward_available?
    cheapest_reward = project.rewards.order("amount asc").first
    cheapest_reward && cheapest_reward.amount >= amount
  end

end
