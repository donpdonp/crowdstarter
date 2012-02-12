require 'spec_helper'

describe User do

  before(:each) do
    info = mock('facebook info', {:email => "some@guy",
                                  :name => "someguy",
                                  :image => "http://image"})
    cred = mock('facebook cred', {:token => "abc123"})                                  
    @hash = mock('omniauth hash', {:uid => 1,
                                  :info => info,
                                  :credentials => cred})
    @existing_user = mock_model(User)                                  
  end

  it "should create a user given an omniauth hash" do
    User.should_receive(:find_by_facebook_uid).with(@hash.uid).and_return(nil)
    User.should_receive(:create)
    User.find_or_create_from_auth_hash(@hash)
  end

  it "should find a user given an omniauth hash" do
    User.should_receive(:find_by_facebook_uid).with(@hash.uid).and_return(@existing_user)

    User.find_or_create_from_auth_hash(@hash).should == @existing_user
  end
end
