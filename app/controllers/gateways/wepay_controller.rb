class Gateways::WepayController < ApplicationController
  def preapproval
    contribution = current_user.contributions.find(params[:contribution_id].to_i)
    if contribution.new? #rename state
      project_owner = contribution.project.user
      if contribution.wepay_preapproval_id.nil?

        preapproval = contribution.wepay_preapproval
        #{"error":"access_denied","error_description":"access token does not have the necessary permissions for this action. Permission required: preapprove_payments","error_code":1010}
        if preapproval["error"]
          RIEMANN << {service:'everythingfunded wepay', tags:['error'],
                      description: preapproval.inspect}
          logger.error preapproval.inspect
          flash[:error] = "Payment processing failed (#{preapproval["error"]}). Please try again."
          redirect_to contribution.project
        else
          if preapproval["preapproval_id"] > 0
            contribution.update_attribute :wepay_preapproval_id, preapproval["preapproval_id"]
            redirect_to preapproval["preapproval_uri"]
          else
            flash[:error] = "Payment processing failed. Please try again."
            redirect_to contribution.project
          end
        end
      else
        wp_params = {:preapproval_id => contribution.wepay_preapproval_id }
        preapproval = contribution.wepay_preapproval_status
        if preapproval["state"] == "new"
          redirect_to preapproval["preapproval_uri"]
        else
          flash[:error] = "This contribution has expired. Please try again."
          redirect_to contribution.project
        end
      end
    end
  end

  def finish
    contribution = current_user.contributions.find_by_wepay_preapproval_id(params[:preapproval_id])
    if contribution

      contribution.wepay_sync

      case contribution.current_state.name
      when :authorized
        flash[:success] = "Thank you! Your contribution has been recorded!"
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
    log = GatewayLog.create(:called_at => Time.now,
                           :verb => "IPN",
                           :url => request.url,
                           :params => params.to_json)
    contribution = Contribution.find_by_wepay_checkout_id(params[:checkout_id])
    if contribution
      migrated_to = contribution.wepay_sync
      log.contribution = contribution
      log.project = contribution.project
      begin
        case migrated_to
        when "authorized"
        when "reserved"
        when "captured"
          contribution.project.activities.create(
                    :detail => "Collected #{contribution.user.email} $#{contribution.amount}",
                    :code => "capture",
                    :contribution => contribution)
          Notifications.delay(:queue => 'mailer').contribution_collected(contribution)
        end
        status = "OK"
      rescue Workflow::TransitionHalted => e
        status = "ERR"
        logger.error e.halted_because
      end
    else
      status = "NOTFOUND"
    end
    response = {:status => status}
    log.response = response.to_json
    log.save
    render :json => response
  end
end