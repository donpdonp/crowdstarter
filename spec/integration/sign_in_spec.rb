require 'spec_helper'

describe "Sign in", :type => :request do
  it "signs in with facebook" do
    visit '/'
    #puts page.html
    within(".user-nav") do
      click_link "facebook-login"
    end
  end
end