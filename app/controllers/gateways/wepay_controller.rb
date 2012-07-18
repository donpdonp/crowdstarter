class Gateways::WepayController < ApplicationController
  def checkout
    contribution = current_user.contributions.find(params[:contribution_id].to_i)
    if contribution.new?
      project_owner = contribution.project.user
      if contribution.wepay_checkout_id.nil?
        wp_params = {
               :account_id => project_owner.wepay_account_id,
               :amount => contribution.amount,
               :short_description => "Contribution to Project ##{contribution.project.id} - #{contribution.project.name}",
               :type => "GOODS",
               :reference_id => "contribution-#{contribution.id}",
               :app_fee => contribution.amount * (SETTINGS.fee_percentage/100.0),
               :fee_payer => "Payee",
               :redirect_uri => gateways_wepay_finish_url,
               :auto_capture => 0,
               :require_shipping => 0,
          }
        wp_params.merge!(:callback_uri => gateways_wepay_ipn_url) unless Rails.env.development?
        logger.tagged("wepay params") { logger.info wp_params.inspect }
        checkout = project_owner.wepay.get('/v2/checkout/create', :params => wp_params).parsed
        logger.tagged("wepay response") { logger.info checkout.inspect }
        if checkout["checkout_id"] > 0
          contribution.update_attribute :wepay_checkout_id, checkout["checkout_id"]
          redirect_to checkout["checkout_uri"]
        else
          flash[:error] = "Payment processing failed. Please try again."
          redirect_to contribution.project
        end
      else
        wp_params = {:checkout_id => contribution.wepay_checkout_id }
        logger.tagged("wepay params") { logger.info wp_params.inspect }
        checkout = project_owner.wepay.get('/v2/checkout',
                                           :params => wp_params).parsed
        logger.tagged("wepay response") { logger.info checkout.inspect }
        if checkout["state"] == "new"
          redirect_to checkout["checkout_uri"]
        else
          flash[:error] = "This contribution has expired. Please try again."
          redirect_to contribution.project
        end
      end
    end
  end

  def finish
    contribution = current_user.contributions.find_by_wepay_checkout_id(params[:checkout_id])
    if contribution
      project_owner = contribution.project.user
      checkout = project_owner.wepay.get('/v2/checkout/',
                                        :params => {
                                          :checkout_id =>
                                            contribution.wepay_checkout_id}).parsed
      logger.tagged("wepay response") { logger.info checkout.inspect }
      case checkout["state"]
      when "authorized"
        contribution.authorize!
        flash[:success] = "Thank you! Your contribution has been recorded!"
        Activity.create({:detail => "Contributed $#{contribution.amount}",
                         :code => "contributed",
                         :contribution => contribution,
                         :user => contribution.user,
                         :project => contribution.project})
        Notifications.delay(:queue => 'mailer').contribution_thanks(contribution)
        flash[:success] = "Contribution received!"
      else
        flash[:error] = "An error occured processing the contribution."
      end
      redirect_to contribution.project
    else
      flash[:error] = "There is no record for that contribution."
      redirect_to :root
    end
  end

  def ipn
    contribution = Contribution.find_by_wepay_checkout_id(params[:checkout_id])
    checkout = contribution.wepay_status
    begin
      case checkout["state"]
      when "authorized"
        contribution.authorize!
        status = "OK"
      when "reserved"
        contribution.reserve!
        status = "OK"
      when "captured"
        contribution.capture!
        status = "OK"
      end
    rescue Workflow::TransitionHalted => e
      status = "ERR"
      logger.error e.halted_because
    end
    render :json => {:status => status}
  end
end