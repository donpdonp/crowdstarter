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

PProject = Hashie::Mash.new({
})

describe "Project management", :type => :request do
  it "Creates a new project using the big Add button" do
    # Manager creates project
    OmniAuth.config.mock_auth[:facebook] = PManager
    visit '/'
    fill_in 'email', :with => PManager.info.email
    click_button "Sign in"

    # Check that we're logged in
    page.should have_content(PManager.info.email)

    # Setup Wepay token
    wpauth = mock("Wepay auth", {:get_token => mock("Wepay token",
                                                    {:params => {},
                                                     :token => '1234',
                                                     :refresh_token => 'abc',
                                                     :expires_at => 'ab'})})
    WEPAY.should_receive(:auth_code).and_return(wpauth)
    manager_wepay = mock("manager wepay")
    manager_wepay.should_receive(:get).with('/v2/account/find',
                                         {:params=>{
                                            :reference_id=>"everythingfunded"}}).
                                    and_return(mock("wepay response",
                                                    {:parsed => ['fake account']}))
    OAuth2::AccessToken.should_receive(:from_hash).and_return(manager_wepay)
    visit "/payment/wepay_request?code=abc123"

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

    #Amazon Payments
    #reference = find(:xpath, "//input[@name='callerReference']")["value"]
    #click_on "Continue to Amazon Payments"

    #WePay
    #reference = find(:xpath, "//input[@name='contribution_id']")["value"]
    user_wepay = mock("user wepay")
    OAuth2::AccessToken.should_receive(:from_hash).and_return(user_wepay)
    resp = mock("wepay checkout", :parsed => {"checkout_id" => 1,
                                              "checkout_uri" => "uri"})
    user_wepay.should_receive(:get).and_return(resp)
    click_on "Continue to WePay Checkout"

    #Amazon callback
    #visit "/payment/receive?callerReference=#{reference}&tokenID=abczzz&status=SC"


    #WePay callback
    visit "/gateways/wepay/finish?checkout_id=123456"

    within(".contributors") do
      page.should have_content("Customer Person $10")
    end
  end
end
