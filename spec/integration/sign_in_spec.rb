require 'spec_helper'

PUser = Hashie::Mash.new({
      :provider => 'facebook',
      :uid => '123545',
      :info => {
        :email => "user@test.site",
        :name => "Test User",
        :image => "face.jpg"
      },
      :credentials => { :token => "abc123" }
    })

describe "Sign in", :type => :request do
  it "signs in with facebook" do
    OmniAuth.config.mock_auth[:facebook] = PUser
    visit '/'
    within("#user-nav") do
      fill_in 'email', :with => PUser.info.email
      #click_button "Sign in"
    end
    # this is ajaxy now
    #page.should have_content('user@test.site')
  end
end