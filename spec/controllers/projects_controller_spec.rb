require 'spec_helper'

describe ProjectsController do

  describe "when signed in" do
    before(:each) do
      @activities_delegate = mock('project activities', :create => nil)
      @project = mock_model(Project, :activities => @activities_delegate)

      @projects_delegate = mock('user projects')
      @user = mock_model(User, :projects => @projects_delegate)

      subject.stub!(:current_user).and_return(@user)
      subject.should_receive(:require_login).and_return(true)
    end

    it "should publish a project" do
      @projects_delegate.should_receive(:find).with(@project.id.to_s).and_return(@project)
      @project.should_receive(:publish!)
      delay = mock('delay')
      delay.should_receive(:end_of_project_processing)
      @project.should_receive(:delay).and_return(delay)
      post :publish, {id: @project.id}
    end

    it "should unpublish a project" do
      @projects_delegate.should_receive(:find).with(@project.id.to_s).and_return(@project)
      @project.should_receive(:unpublish!)
      post :unpublish, {id: @project.id}
    end
  end
end
