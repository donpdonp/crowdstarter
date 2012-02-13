class ProjectsController < ApplicationController
  def new
    @project = Project.new
  end

  def create
    project = Project.create(params[:project])
    redirect_to project || :root
  end
  
  def show
    @project = Project.find(params[:id])
  end
end
