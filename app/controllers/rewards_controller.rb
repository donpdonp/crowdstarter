class RewardsController < ApplicationController
  before_filter :require_login, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :editable_project, :only => [:new, :create, :edit, :update]

  def new
    @reward = Reward.new
  end

  def create
    unless @project.editable?
      flash[:error] = "Project is not editable"
    end
    reward = @project.rewards.create(params[:reward])
    if reward.valid?
      @project.activities.create({:detail => "Reward added at $#{"%0.2f" % reward.amount}",
                                  :code => "reward",
                                  :user => current_user})
    else
      flash[:error] = "Reward creation failed. #{reward.errors.full_messages.join(' ')}"
    end
    redirect_to @project
  end

  def editable_project
    @project = current_user.projects.find(params[:project_id])
    unless @project.editable?
      flash[:error] = "Project is not editable"
      redirect_to @project
    end
  end

  def destroy
    # todo: use cancan
    reward = Reward.find(params[:id])
    if reward
      project = reward.project
      target = project
      if project.user == current_user
        reward.destroy
      end
    else
      target = :root
    end
    redirect_to target
  end
end
