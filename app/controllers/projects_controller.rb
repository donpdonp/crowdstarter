class ProjectsController < ApplicationController
  def new
    if logged_in?
      @project = Project.new
    else
      flash[:error] = "Login first"
      redirect_to :root
    end
  end

  def create
    project = Project.create(params[:project])
    redirect_to project || :root
  end
  
  def show
    @project = Project.find(params[:id])
  end
end
