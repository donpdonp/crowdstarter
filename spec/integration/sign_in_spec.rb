require 'spec_helper'

describe "Sign in", :type => :request do
  it "signs in with facebook" do
    visit '/'
    within(".user-nav") do
      click_link "facebook-login"
    end
    page.should have_content('user@test.site')
  end
end