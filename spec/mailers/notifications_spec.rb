require "spec_helper"

describe Notifications do
  describe "thanks" do

    before(:each) do
      @user = mock_model(User, {username: "testuser", email: "em@ail.com"})
      @project = mock_model(Project, {name: "My Test Project"})
      @contribution = Contribution.new

      @contribution.should_receive(:user).twice.and_return(@user)
      @contribution.should_receive(:project).and_return(@project)
      @contribution.should_receive(:amount).and_return(29.95)
    end

    it "renders the headers" do
      mail = Notifications.thanks(@contribution)

      mail.subject.should eq("Thanks for your donation!")
      mail.to.should eq(["em@ail.com"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail = Notifications.thanks(@contribution)

      mail.body.encoded.should match("Hi")
    end
  end

end
