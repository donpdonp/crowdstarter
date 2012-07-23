class Contribution < ActiveRecord::Base
  include Workflow
  include Wepay

  belongs_to :project
  belongs_to :user
  belongs_to :reward
  belongs_to :gateway

  has_many :gateway_logs
  validates :amount, :numericality => true

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

  def amazon_authorize(token, status)
    update_attribute :token, token
    update_attribute :status, status
    approve! if status == "SC"
  end

  def capture
  end

  def wepay_capture
    wp_params = {:checkout_id => wepay_checkout_id}
    logger.info "/v2/checkout/capture #{wp_params.inspect}"
    payment = project.user.wepay.get("/v2/checkout/capture",
                             :params => wp_params).parsed
    logger.info payment.inspect
  end

  def amazon_capture
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

  def wepay_cancel
    begin
      payment = project.user.wepay.get("/v2/checkout/cancel",
                               :params => {:checkout_id => wepay_checkout_id,
                                           :cancel_reason => "Cancelled by customer request"}).parsed
      logger.info payment.inspect
      if payment["state"] != "cancelled"
        logger.error "Payment cancellation failed!"
        halt
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
