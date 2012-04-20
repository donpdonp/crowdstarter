require 'spec_helper'

describe "Project management", :type => :request do
  it "Creates a new project using the big Add button" do
    visit '/'
    click_on "facebook-login"
    click_on "Add a project"
    page.has_css?("form#new_project")
    fill_in('Project Name', :with => "A new pony")
    fill_in('Collection amount', :with => "35")
    fill_in('Funding due', :with => 5.days.from_now)
    click_on "Save Details"
    page.should have_content("This project is not published.")
    click_on "Publish"
    page.should have_content("Publish Project")
    click_on "Publish"
    page.should have_content("Project now published!")
  end
end
