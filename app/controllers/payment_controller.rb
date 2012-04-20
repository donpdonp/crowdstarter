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
    contribution = Contribution.find_by_reference(params[:callerReference])
    if contribution
      contribution.receive_payment(params[:tokenID], params[:status])
      redirect_to contribution.project
    end
  end
end
