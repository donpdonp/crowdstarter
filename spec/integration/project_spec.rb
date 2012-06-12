require 'spec_helper'

PManager = Hashie::Mash.new({
      :provider => 'facebook',
      :uid => '123545',
      :info => {
        :email => "manager@test.site",
        :name => "Manager Person",
        :image => "face.jpg"
      },
      :credentials => { :token => "abc123" }
    })

PCustomer = Hashie::Mash.new({
      :provider => 'facebook',
      :uid => '123546',
      :info => {
        :email => "customer@test.site",
        :name => "Customer Person",
        :image => "face.jpg"
      },
      :credentials => { :token => "abc124" }
    })

describe "Project management", :type => :request do
  it "Creates a new project using the big Add button" do
    # Manager creates project
    OmniAuth.config.mock_auth[:facebook] = PManager
    visit '/'
    click_on "facebook-login"
    page.should have_content("manager@test.site")

    # Setup Amazon multiuse token
    visit "/payment/tokenize?tokenID=abc123"

    visit '/'
    click_on "Add a project"
    page.has_css?("form#new_project")
    fill_in('Project Name', :with => "A new pony")
    fill_in('Collection amount', :with => "35")
    fill_in('Funding due', :with => 5.days.from_now)
    click_on "Save Details"
    page.should have_content("This project is not published.")
    click_on "Add a reward"
    page.should have_content("earn this reward")
    fill_in('reward-amount', :with => "3")
    fill_in('reward-description', :with => "A Pony")
    click_on "Add Reward"
    page.should have_content("$3.00 or more")
    click_on "Publish"
    page.should have_content("Publish Project")
    click_on "Publish"
    page.should have_content("Project now published!")
    click_on "logout"

    # Customer donates
    OmniAuth.config.mock_auth[:facebook] = PCustomer
    visit '/'
    click_on "facebook-login"
    page.should have_content("customer@test.site")
    visit '/projects/a-new-pony'
    page.should have_content("Contribute to this project")
    fill_in("Amount", :with => "10")
    click_on "Give"
    page.should have_content("Contribute $10.00 to")
    #click_on "Continue to Amazon Payments"
    reference = find(:xpath, "//input[@name='callerReference']")["value"]

    #Amazon callback
    visit "/payment/receive?callerReference=#{reference}&tokenID=abczzz&status=SC"
    within(".contributors") do
      page.should have_content("Customer Person $10")
    end
  end
end
