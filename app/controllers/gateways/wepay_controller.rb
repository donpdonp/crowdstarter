class Gateways::WepayController < ApplicationController
  def checkout
    contribution = current_user.contributions.find(params[:contribution_id].to_i)
    wp_params = {
           :account_id => contribution.project.user.wepay_account_id,
           :amount => contribution.amount,
           :short_description => "Contribution to Project #{contribution.project.id}",
           :type => "GOODS",
           :reference_id => "contribution-#{contribution.id}",
           :app_fee => contribution.amount * (SETTINGS['aws']['fee_percentage']/100.0),
           :fee_payer => "Payee",
           :redirect_uri => gateways_wepay_finish_url,
           :auto_capture => 0,
           :require_shipping => 1,
      }
    wp_params.merge!(:callback_uri => "http://requestb.in/12ejzjd1")
    logger.info wp_params.inspect
    resp = current_user.wepay.get('/v2/checkout/create', :params => wp_params)
    checkout = JSON.parse(resp.body)
    logger.info checkout.inspect
    if checkout["checkout_id"] > 0
      contribution.update_attribute :wepay_checkout_id, checkout["checkout_id"]
      redirect_to checkout["checkout_uri"]
    else
      flash[:error] = "Payment processing failed."
      redirect_to contribution.project
    end
  end

  def finish
    contribution = current_user.contributions.find_by_wepay_checkout_id(params[:checkout_id])
    resp = current_user.wepay.get('/v2/checkout/', :params => {:checkout_id => contribution.wepay_checkout_id})
    checkout = JSON.parse(resp.body)
    logger.info checkout.inspect
    case checkout["state"]
    when "authorized"
      flash[:info] = "Your contribution will be processed shortly."
    when "reserved"
      contribution.approve!
      flash[:success] = "Your contribution has been recorded!"
    else
      flash[:error] = "An error occured processing the contribution."
    end
    redirect_to contribution.project
  end

  def ipn
    contribution = Contribution.find_by_wepay_checkout_id(params[:checkout_id])
    if contribution.incomplete?
      checkout = contribution.user.wepay.get('/v2/checkout/', :params => {:checkout_id => contribution.wepay_checkout_id})
      logger.info checkout.parsed.inspect
      case checkout.parsed["state"]
      when "reserved"
        contribution.approve!
        status = "OK"
      end
    else
      status = "Already processed"
    end
    render :json => {:status => status}
  end
end