require 'spec_helper'

describe User do

  before(:each) do
    info = double('facebook info', {:email => "some@guy",
                                  :name => "someguy",
                                  :image => "http://image"})
    cred = double('facebook cred', {:token => "abc123"})
    @hash = double('omniauth hash', {:uid => 1,
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

  it "should build a hash from json" do
    user = User.new
    user.wepay_token = "{\"user_id\":28,\"token_type\":\"BEARER\",\"access_token\":\"b1ba\",\"refresh_token\":null,\"expires_at\":null}"
    user.wepay_token_hash["token_type"].should == "BEARER"
  end
end
