class ProjectsController < ApplicationController
  before_filter :require_login, :only => [:edit, :publish_review, :publish,
                                          :destroy, :contribute]

  def index
    if params[:user]
      # username search
      @user = User.find(params[:user])
      if @user
        @projects = Project.where(:user_id => @user.id)
      else
        flash[:error] = "No user #{params[:user]}"
        redirect_to root_path
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
      flash[:error] = "Login first"
      redirect_to :root
    end
  end

  def create
    if logged_in?
      params[:project][:funding_due] += " #{params[:timezone]}"
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
        end
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
    current_user.projects.find(params[:id]).destroy
    redirect_to :root
  end

  def contribute
    project = Project.find(params[:id])
    @contribution = project.contributions.create(
                           :user_id => current_user.id,
                           :amount => params[:amount],
                           :reference => "proj:#{project.id}-fbid:#{current_user.facebook_uid}-time:#{Time.now.to_i}")
    if @contribution.valid?
      reward = @contribution.nearest_reward
      if reward
        @contribution.update_attribute :reward_id, reward.id
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
    if @project.user.aws_token.blank?
      flash[:error] = "Please connect your account to Amazon Payments first"
      redirect_to @project.user
    end
  end

  def publish
    @project = Project.find(params[:id])
    @project.publish!
    @project.delay(run_at:@project.funding_due).end_of_project_processing
    flash[:success] = "Project now published!"
    @project.activities.create({:detail => "Project published",
                               :code => "publish",
                               :user => current_user})

    redirect_to @project
  end
end
