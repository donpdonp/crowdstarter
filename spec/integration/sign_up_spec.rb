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

def signup_setup
end

describe "Sign up", :type => :request do
  it "with facebook" do
    signup_setup

    visit '/'
    within("#modal-signup") do
      fill_in 'email', :with => PUser.info.email
      fill_in 'username', :with => "testuser"
      fill_in 'password', :with => "abc123"
      click_button "Sign up"
    end
puts page.body
    within('.user-detail') do
      page.should have_content('user@test.site')
    end
  end
end