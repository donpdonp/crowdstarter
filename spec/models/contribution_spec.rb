require 'spec_helper'

describe Contribution do
  it "receives payment" do
   subject.should_receive(:update_attribute).with(:token, "token")
   subject.should_receive(:update_attribute).with(:status, "SC")
   subject.should_receive(:approve!)
   subject.amazon_authorize("token","SC")
  end

end
