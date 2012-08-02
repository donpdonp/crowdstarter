class ProjectsController < ApplicationController
  before_filter :require_login, :only => [:edit, :publish_review, :publish,
                                          :destroy, :contribute, :unpublish]

  include ActionView::Helpers::NumberHelper

  def index
    if params[:user]
      # username search
      @user = User.find(params[:user])
      if @user
        @projects = @user.projects.fundables
      else
        render :file => "#{Rails.root}/public/404.html",
               :status => :not_found,
               :layout => nil
      end
    else
      @projects = Project.fundables.limit(10).order(:funding_due)
    end
  end

  def new
    if logged_in?
      @project = current_user.projects.build
      @project.funding_due = 1.week.from_now
    else
      flash[:error] = "Please sign in to begin creating your funding project."
      redirect_to :root
    end
  end

  def create
    if logged_in?
      params[:project][:funding_due] += " #{params[:timezone]}"
      params[:project][:gateway_id] = Gateway.find_by_provider(SETTINGS.default_payment_gateway).id
      project = current_user.projects.create(params[:project])
      if project.valid?
        project.activities.create({:detail => "Created project",
                                   :code => "create",
                                   :user => current_user})
        redirect_to project
      else
        flash[:error] = "invalid project"
        redirect_to new_project_path
      end
    else
      redirect_to :root
    end
  end

  def show
    begin
      @project = Project.find(params[:id])
      if @project.editable?
        if logged_in? && current_user == @project.user
        else
          flash[:info] = "Project #{params[:id]} is not finished"
          redirect_to root_path
          return
        end
      end
      respond_to do |format|
        format.html
        format.json { render :json => {:name => @project.name,
                                       :amount => @project.amount,
                                       :contributed => @project.contributed_amount,
                                       :state => @project.workflow_state,
                                       :collected => @project.collected_amount,
                                       :funding_due => @project.funding_due} }
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Project #{params[:id]} not found"
      redirect_to root_path
    end
  end

  def edit
    begin
      @project = current_user.projects.find(params[:id])
      unless @project.editable?
        flash[:error] = "Project is not editable"
        redirect_to @project
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Project #{params[:id]} not found"
      redirect_to root_path
    end
  end

  def update
    project = current_user.projects.find(params[:id])
    params[:project][:funding_due] += " #{params[:timezone]}"
    logger.info "new date "+params[:project][:funding_due]
    project.update_attributes params[:project]
    redirect_to project
  end

  def destroy
    project = current_user.projects.find(params[:id])
    if project.editable?
      project.destroy
    else
      flash[:error] = "Project must be editable to remove."
    end
    redirect_to :root
  end

  def contribute
    project = Project.find(params[:id])
    @contribution = project.contributions.create(
                           :user_id => current_user.id,
                           :amount => params[:amount],
                           :reference => "proj:#{project.id}-fbid:#{current_user.facebook_uid}-time:#{Time.now.to_i}",
                           :gateway_id => project.gateway_id)
    if @contribution.valid?
      reward = project.closest_reward(@contribution.amount)
      if reward
        @contribution.update_attribute :reward_id, reward.id
      else
        flash[:error] = "The minimum reward for this project requires a contribution of #{number_to_currency(project.smallest_reward.amount)}"
        redirect_to project
      end
    else
      flash[:error] = "There is a problem with the contribution: "+
                       @contribution.errors.full_messages.join('. ')
      redirect_to project
    end
  end

  def count
    stats = {:created => Project.where("created_at > ?",
                           params[:hours].to_i.hours.ago).count,
             :contributed => Contribution.where("created_at > ?",
                             params[:hours].to_i.hours.ago).count }
    render :json => stats
  end

  def publish_review
    @project = Project.find(params[:id])
    if @project.user.wepay_token.blank?
      flash[:error] = "Please connect your account to a payment gateway."
      redirect_to user_path(@project.user, :tab=>"payment_gateway")
    end
  end

  def publish
    begin
      @project = current_user.projects.find(params[:id])
      @project.publish!
      @project.delay(run_at:@project.funding_due).end_of_project_processing
      flash[:success] = "Project now published!"
      @project.activities.create({:detail => "Project published",
                                 :code => "publish",
                                 :user => current_user})
    rescue Workflow::TransitionHalted => e
      flash[:error] = e.halted_because
    end
    redirect_to @project
  end

  def unpublish
    @project = current_user.projects.find(params[:id])
    contributions = @project.contributions
    if contributions.authorizeds.count + contributions.reserveds.count == 0
      @project.unpublish!
      flash[:success] = "Project has been unpublished!"
      @project.activities.create({:detail => "Project unpublished",
                                 :code => "unpublish",
                                 :user => current_user})
    else
      flash[:success] = "Project has contributions and cannot be unpublished."
    end

    redirect_to @project
  end
end
