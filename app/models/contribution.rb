class Contribution < ActiveRecord::Base
  include Workflow

  belongs_to :project
  belongs_to :user

  scope :authorizeds, where(:workflow_state => :authorized)

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
  end

end
