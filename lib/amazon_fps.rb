module AmazonFps
  def amazon_authorize(token, status)
    update_attribute :token, token
    update_attribute :status, status
    approve! if status == "SC"
  end

  def amazon_capture
    payment = FPS.pay( caller_reference:      "proj:#{project.id}-ctrb:#{id}-#{rand(100)}",
                     marketplace_variable_fee: SETTINGS.payment_gateways.amazon.fee_percentage.to_s,
                     recipient_token_id:    project.user.aws_token,
                     sender_token_id:       token,
                     transaction_amount:    amount.to_s )
    update_attribute :txid, payment[:transaction_id]
  end

  def amazon_cancel
    response = FPS.cancel_token(token_id: token)
    update_attribute :cancel_request_id, response[:request_id]
  end
end