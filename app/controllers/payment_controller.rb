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
            contribution.amazon_authorize(params[:tokenID], params[:status])
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
    gateway = Gateway.find_by_provider(current_user.payment_gateway)
    token = gateway.client.auth_code.get_token(params[:code],
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
    redirect_to user_path(current_user, :tab=>"payment_gateway")
  end

  def wepay_account
    gateway = Gateway.find_by_provider(current_user.payment_gateway)
    wepay_api = OAuth2::AccessToken.from_hash(gateway.client,
                                  current_user.wepay_token_hash)
    wepay_account = {:name => "EverythingFunded",
                    :description => "Contributions to projects",
                    :reference_id => "everythingfunded"}
    accounts = wepay_api.get('/v2/account/find', :params => {
                             :reference_id => wepay_account[:reference_id]}).parsed
    if accounts.size > 0
      account = accounts.first
      account_id = account["account_id"]
    else
      # Create one
      new_account = wepay_api.get('/v2/account/create', :params => wepay_account).parsed
      account_id = new_account["account_id"]
    end
    flash[:info] = "A WePay account is connected and ready receive contributions!"
    current_user.update_attribute :wepay_account_id, account_id
    redirect_to current_user
  end
end
