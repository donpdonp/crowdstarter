class PaymentController < ApplicationController
  def tokenize
    current_user.update_attribute :aws_token, params["tokenID"]
    current_user.update_attribute :aws_token_refund, params["refundTokenID"]
    redirect_to current_user
  end

  def clear
    current_user.update_attribute :aws_token, nil
    current_user.update_attribute :aws_token_refund, nil
    redirect_to current_user
  end

  def receive
    begin
      #["controller", "action"].each{|k| params.delete(k)}
      #valid = FPS.verify_signature?(payment_receive_url, params)
      #if valid
        contribution = Contribution.find_by_reference(params[:callerReference])
        if contribution
          if contribution.incomplete?
            contribution.receive_payment(params[:tokenID], params[:status])
            if contribution.authorized?
              Activity.create({:detail => "Contributed $#{contribution.amount}",
                               :code => "contributed",
                               :contribution => contribution,
                               :user => contribution.user,
                               :project => contribution.project})
              Notifications.delay(:queue => 'mailer').contribution_thanks(contribution)
              flash[:success] = "Contribution received!"
            end
          else
            flash[:error] = "The contribution has already been processed"
          end
          redirect_to contribution.project
        else
          flash[:error] = "Amazon response not understood"
          redirect_to :root
        end
      #end
    rescue Boomerang::Errors::HTTPError => e
      logger.error e.message
      render :json => e.message
    end
  end

  def wepay_request
    # convert request token into access token
    token = WEPAY.auth_code.get_token(params[:code],
                :redirect_uri => payment_wepay_request_url)
    token_hash = token.params.merge({:access_token => token.token,
                                     :refresh_token => token.refresh_token,
                                     :expires_at => token.expires_at})
    current_user.update_attribute :wepay_token, token_hash.to_json
    flash[:info] = "WePay connected successfully!"
    redirect_to payment_wepay_account_path
  end

  def wepay_clear
    current_user.update_attribute :wepay_token, nil
    flash[:info] = "WePay connection removed."
    redirect_to current_user
  end

  def wepay_account
    wepay_params = {:name => "EverythingFunded",
                    :description => "Contributions to projects",
                    :reference_id => "everythingfunded"}
    resp = current_user.wepay.get('/v2/account/find', :params => {
                             :reference_id => wepay_params[:reference_id]})
    accounts = JSON.parse(resp.body)
    if accounts.size > 0
      account = accounts.first
      account_id = account["account_id"]
    else
      # Create one
      resp = current_user.wepay.get('/v2/account/create', :params => wepay_params)
      new_account = JSON.parse(resp.body)
      account_id = new_account["account_id"]
    end
    flash[:info] = "A WePay account is connected and ready receive contributions!"
    current_user.update_attribute :wepay_account_id, account_id
    redirect_to current_user
  end

  def wepay_checkout
    contribution = current_user.contributions.find(params[:contribution_id].to_i)
    wp_params = {
           :account_id => contribution.project.user.wepay_account_id,
           :amount => contribution.amount,
           :short_description => "Contribution to Project #{contribution.project.id}",
           :type => "GOODS",
           :reference_id => "contribution-#{contribution.id}",
           :app_fee => contribution.amount * (SETTINGS['aws']['fee_percentage']/100.0),
           :fee_payer => "Payee",
           :redirect_uri => payment_wepay_finish_url,
           :auto_capture => 0,
           :require_shipping => 1,
      }
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

  def wepay_finish
    contribution = current_user.contributions.find_by_wepay_checkout_id(params[:checkout_id])
    resp = current_user.wepay.get('/v2/checkout/', :params => {:checkout_id => contribution.wepay_checkout_id})
    checkout = JSON.parse(resp.body)
    logger.info checkout.inspect
    case checkout["state"]
    when "authorized"
      flash[:info] = "Your contribution will be processed shortly."
    when "reserved"
      contribution.approve!
    else
      flash[:error] = "An error occured processing the contribution."
    end
    redirect_to contribution.project
  end
end
