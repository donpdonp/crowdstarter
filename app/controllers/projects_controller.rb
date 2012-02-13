class ProjectsController < ApplicationController
  def new
    if logged_in?
      @project = current_user.projects.build
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
    @project = current_user.projects.find(params[:id])
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
end
