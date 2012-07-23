module Wepay
  def wepay_api
    Oauth2Logger.new(gateway.client, project.user, self)
  end

  def wepay_status
    wp_params = {:checkout_id => wepay_checkout_id}
    wepay_api.get("/v2/checkout",
                   :params => wp_params)
  end

  def wepay_checkout(finish_url, ipn_url)
    wp_params = {
           :account_id => project.user.wepay_account_id,
           :amount => self.amount,
           :short_description => "Contribution to Project ##{project.id} - #{project.name}",
           :type => "GOODS",
           :reference_id => "contribution-#{id}",
           :app_fee => amount * (SETTINGS.fee_percentage/100.0),
           :fee_payer => "Payee",
           :redirect_uri => finish_url,
           :auto_capture => 0,
           :require_shipping => 0,
      }
    wp_params.merge!(:callback_uri => ipn_url) unless Rails.env.development?
    wepay_api.get('/v2/checkout/create', :params => wp_params)
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
