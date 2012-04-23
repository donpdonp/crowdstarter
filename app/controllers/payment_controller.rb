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
          contribution.receive_payment(params[:tokenID], params[:status])
          if contribution.authorized?
            Activity.create({:detail => "contributed",
                             :code => "contributed",
                             :contribution => contribution,
                             :user => contribution.user,
                             :project => contribution.project})
          end
          redirect_to contribution.project
        end
      #end
    rescue Boomerang::Errors::HTTPError => e
      logger.error e.message
      render :json => e.message
    end
  end
end
