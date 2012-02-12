require 'spec_helper'

describe SessionController do

  it "should login a user" do
    new_user = mock_model(User)
    User.should_receive(:find_or_create_from_auth_hash).and_return(new_user)
    post :create
    session[:logged_in_user_id].should == new_user.id
    response.should redirect_to(:root)
  end

end
