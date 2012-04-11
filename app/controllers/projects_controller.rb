class ProjectsController < ApplicationController
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
      project = current_user.projects.create(params[:project])
      if project.valid?
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
    @project = Project.find(params[:id])
  end

  def edit
    @project = current_user.projects.find_by_id(params[:id])
    if @project
      unless @project.editable?
        flash[:error] = "Project is not editable"
        redirect_to @project
      end
    else
      flash[:error] = "Project #{params[:id]} not found"
      redirect_to root_path
    end
  end

  def update
    project = current_user.projects.find(params[:id])
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
  end
end
