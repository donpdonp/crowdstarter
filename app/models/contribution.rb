class Contribution < ActiveRecord::Base
  include Workflow

  belongs_to :project
  belongs_to :user
  belongs_to :reward

  validates :amount, :numericality => true

  scope :authorizeds, where(:workflow_state => :authorized)

  #after_create :thank_the_user
  workflow do
    state :incomplete do
      event :approve, :transitions_to => :authorized
    end
    state :authorized do
      event :collect, :transitions_to => :collected
      event :cancel, :transitions_to => :cancelled
    end
    state :collected
    state :cancelled
  end

  def thank_the_user
    Notification.thanks(self)
  end

  def receive_payment(token, status)
    update_attribute :token, token
    update_attribute :status, status
    approve! if status == "SC"
  end

  def collect_payment_for(receiving_user)
    payment = FPS.pay( caller_reference:      "proj:#{project.id}-ctrb:#{id}-#{rand(100)}",
                     marketplace_variable_fee: SETTINGS['aws']['fee_percentage'].to_s,
                     recipient_token_id:    receiving_user.aws_token,
                     sender_token_id:       token,
                     transaction_amount:    amount.to_s )
    update_attribute :txid, payment[:transaction_id]
  end

  def reward_available?
    cheapest_reward = project.rewards.order("amount asc").first
    cheapest_reward && cheapest_reward.amount >= amount
  end

  def nearest_reward
    rewards = project.rewards.order("amount asc")
    rewards.select{|r| amount >= r.amount}.last
  end

  def cancel
    response = FPS.cancel_token(token_id: token)
    update_attribute :cancel_request_id, response[:request_id]
  end
end
