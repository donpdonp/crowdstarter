class RewardsController < ApplicationController
  before_filter :require_login, :only => [:new, :create, :edit, :update]

  def new
    @project = Project.find(params[:project_id])
    @reward = Reward.new
  end

  def create
    @project = current_user.projects.find(params[:project_id])
    @project.rewards.create(params[:reward])
    redirect_to @project
  end
end
