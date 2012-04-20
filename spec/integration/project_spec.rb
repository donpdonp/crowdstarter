require 'spec_helper'

describe "Project management", :type => :request do
  it "Creates a new project using the big Add button" do
    visit '/'
    click_link "facebook-login"
    click_link "Add a project"
    page.has_css?("form#new_project")
  end
end