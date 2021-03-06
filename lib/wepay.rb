module Wepay
  def wepay_api
    Oauth2Logger.new(gateway.client, project.user, self)
  end

  def wepay_checkout_status
    wp_params = {:checkout_id => wepay_checkout_id}
    wepay_api.get("/v2/checkout",
                   :params => wp_params)
  end

  def wepay_preapproval_status
    wp_params = {:preapproval_id => wepay_preapproval_id}
    wepay_api.get("/v2/preapproval",
                   :params => wp_params)
  end

  def wepay_sync
    if wepay_checkout_id
      # get a fresh state from WePay
      state_wepay = wepay_checkout_status["state"]

      if wepay_state_match?(state_wepay)
        logger.info "Contribution #{id} in sync local:#{workflow_state} == wepay:checkout:#{state_wepay}"
      else
        wepay_migrate_to(state_wepay)
        state_wepay
      end
    else
      if wepay_preapproval_id
        state_wepay = wepay_preapproval_status["state"]
        if wepay_preapproval_state_match?(state_wepay)
          logger.info "Contribution #{id} in sync local:#{workflow_state} == wepay:preapproval:#{state_wepay}"
        else
          wepay_preapproval_migrate_to(state_wepay)
        end
      end
    end
  end

  def wepay_state_match?(state_wepay)
    # translate between the gateway's state machine and ours
    case workflow_state
    when "cancelled"
      ["cancelled", "failed"].include?(state_wepay)
    else
      workflow_state == state_wepay
    end
  end

  def wepay_preapproval_state_match?(state_wepay)
    # translate between the gateway's state machine and ours
    case workflow_state
    when "authorized"
      state_wepay == "approved"
    when "cancelled"
      ["cancelled", "expired", "revoked"].include?(state_wepay)
    else
      false
    end
  end

  def wepay_preapproval_migrate_to(state_wepay)
    logger.info "Contribution #{id} preapproval migrating from local:#{workflow_state} to wepay:preapproval:#{state_wepay}"
    case state_wepay
    when "approved"
      authorize!
    when "revoked"
      cancel!
    when "expired"
      cancel!
    when "cancelled"
      cancel!
    else
      logger.info "Contribution #{id} preapproval unknown migration path from local:#{workflow_state} to wepay:preapproval:#{state_wepay}"
    end
  end

  def wepay_migrate_to(state_wepay)
    logger.info "Contribution #{id} migrating from local:#{workflow_state} to wepay:checkout:#{state_wepay}"
    case state_wepay
    when "authorized"
      authorize!
    when "reserved"
      reserve!
    when "captured"
      capture!
    when "cancelled"
      cancel!
    when "failed"
      cancel!
    else
      logger.info "Contribution #{id} unknown migration path from local:#{workflow_state} to wepay:checkout:#{state_wepay}"
    end
  end

  def finish_url
    Rails.application.routes.url_helpers.gateways_wepay_finish_url
  end

  def ipn_url
    Rails.application.routes.url_helpers.gateways_wepay_ipn_url
  end

  def wepay_preapproval
    wp_params = {
           :account_id => project.user.wepay_account_id,
           :amount => self.amount,
           :short_description => "Contribution to Project ##{project.id} - #{project.name}",
           :period => "once",
           :reference_id => "contribution-#{id}",
           :app_fee => amount * (SETTINGS.fee_percentage/100.0),
           :fee_payer => "payee",
           :redirect_uri => finish_url,
           :end_time => project.funding_due+3.days
      }
    wp_params.merge!(:callback_uri => ipn_url) unless Rails.env.development?
    wepay_api.get('/v2/preapproval/create', :params => wp_params)
  end

  def wepay_checkout
    wp_params = {
           :account_id => project.user.wepay_account_id,
           :amount => self.amount,
           :short_description => "Contribution to Project ##{project.id} - #{project.name}",
           :type => "GOODS",
           :reference_id => "contribution-#{id}",
           :auto_capture => 0,
           :preapproval_id => self.wepay_preapproval_id
      }
    wp_params.merge!(:callback_uri => ipn_url) unless Rails.env.development?
    wepay_api.get('/v2/checkout/create', :params => wp_params)
  end

  def wepay_capture
    wp_params = {:checkout_id => wepay_checkout_id}
    response = wepay_api.get("/v2/checkout/capture", :params => wp_params)
  end

  def wepay_cancel(reason = "Cancelled by customer request")
    wp_params = {:checkout_id => wepay_checkout_id, :cancel_reason => reason}
    response = wepay_api.get("/v2/checkout/cancel",
                             :params => wp_params)
    wepay_migrate_to(response["state"]) unless response["error"]
  end

  def wepay_preapproval_cancel
    wp_params = {:preapproval_id => wepay_preapproval_id}
    response = wepay_api.get("/v2/preapproval/cancel",
                             :params => wp_params)
    wepay_preapproval_migrate_to(response["state"]) unless response["error"]
  end

end
