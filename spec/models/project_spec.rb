require 'spec_helper'

describe Project do
  before(:each) do
    @project = Project.create({name: 'The Big One',
                               funding_due: 2.days.from_now,
                               amount: 5,
                               user_id: 1,
                               gateway_id: 1})
  end

  context "new/empty project" do
    it "should start empty" do
      @project.contributions.count.should == 0
    end

    it "should be editable" do
      @project.editable?.should be_true
    end

    it "should not be fundable" do
      @project.fundable?.should be_false
    end

    it "should not publish" do
      expect { @project.publish! }.to raise_exception(Workflow::TransitionHalted)
    end
  end

  context "fundable project" do
    before(:each) do
      @project.contributions.create({amount: 10, gateway_id: 1})
    end

    it "should calculate the amount of authorized contributions" do
      @project.authorized_amount.should == 0
    end
  end
end
