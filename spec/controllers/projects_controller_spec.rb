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

    it "should unpublish a project" do
      @projects_delegate.should_receive(:find).and_return(@project)
      @project.should_receive(:unpublish!)
      post :unpublish
    end
  end
end
