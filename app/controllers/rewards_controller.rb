class RewardsController < ApplicationController
  before_filter :require_login, :only => [:new, :create, :edit, :update]

  def new
    @project = Project.find(params[:project_id])
    @reward = Reward.new
  end
end
