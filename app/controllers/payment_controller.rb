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
    current_user.update_attribute :wepay_token, token.token
    flash[:info] = "WePay connected successfully!"
    redirect_to current_user
  end

  def wepay_clear
    current_user.update_attribute :wepay_token, nil
    flash[:info] = "WePay connection removed."
    redirect_to current_user
  end
end
