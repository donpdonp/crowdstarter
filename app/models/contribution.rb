class Contribution < ActiveRecord::Base
  include Workflow

  belongs_to :project
  belongs_to :user
  belongs_to :reward

  validates :amount, :numericality => true

  scope :authorizeds, where(:workflow_state => :authorized)
  scope :reserveds, where(:workflow_state => :reserved)
  scope :collecteds, where(:workflow_state => :collected)
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

  def receive_payment(token, status)
    update_attribute :token, token
    update_attribute :status, status
    approve! if status == "SC"
  end

  def collect
    wepay_collect
  end

  def wepay_collect
    payment = user.wepay.get("/v2/checkout/capture",
                             :params => {:checkout_id => wepay_checkout_id}).parsed
    logger.info payment.inspect
    if payment["state"] == "captured"
      collect!
    end
  end

  def amazon_collect
    payment = FPS.pay( caller_reference:      "proj:#{project.id}-ctrb:#{id}-#{rand(100)}",
                     marketplace_variable_fee: SETTINGS.payment_gateways.amazon.fee_percentage.to_s,
                     recipient_token_id:    project.user.aws_token,
                     sender_token_id:       token,
                     transaction_amount:    amount.to_s )
    update_attribute :txid, payment[:transaction_id]
  end

  def reward_available?
    cheapest_reward = project.rewards.order("amount asc").first
    cheapest_reward && cheapest_reward.amount >= amount
  end

  def cancel
    wepay_cancel
  end

  def wepay_status
    user.wepay.get("/v2/checkout",
                   :params => {:checkout_id => wepay_checkout_id}).parsed
  end

  def wepay_cancel
    begin
      payment = user.wepay.get("/v2/checkout/cancel",
                               :params => {:checkout_id => wepay_checkout_id,
                                           :cancel_reason => "Cancelled by customer request"}).parsed
      logger.info payment.inspect
      if payment["state"] == "cancelled"
        cancel!
      end
    rescue OAuth2::Error => e
      logger.error e
    end
  end

  def amazon_cancel
    response = FPS.cancel_token(token_id: token)
    update_attribute :cancel_request_id, response[:request_id]
  end
end
