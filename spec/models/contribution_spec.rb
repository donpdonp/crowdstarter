require 'spec_helper'

describe Contribution do
  before(:each) do
    @contribution = FactoryGirl.create(:contribution)
  end

  it "creates a new instance given valid attributes" do
    @contribution.should be_valid
  end

  it "sends email when a new contribution is created" do
    pending
    Notifications.should_receive(:thanks)
  end
end
