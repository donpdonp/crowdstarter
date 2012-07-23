module Wepay
  def wepay_api
    Oauth2Logger.new(OAuth2::AccessToken.from_hash(
                                       gateway.client,
                                       project.user.wepay_token_hash),
                     self)
  end

  def wepay_status
    wp_params = {:checkout_id => wepay_checkout_id}
    wepay_api.get("/v2/checkout",
                   :params => wp_params)
  end

  def wepay_capture
    wp_params = {:checkout_id => wepay_checkout_id}
    wepay_api.get("/v2/checkout/capture",
                             :params => wp_params).parsed
  end

  def wepay_cancel
    begin
      payment = wepay_api.get("/v2/checkout/cancel",
                               :params => {:checkout_id => wepay_checkout_id,
                                           :cancel_reason => "Cancelled by customer request"}).parsed
      if payment["state"] != "cancelled"
        logger.error "Payment cancellation failed!"
      end
    rescue OAuth2::Error => e
      logger.error e
    end
  end

end
