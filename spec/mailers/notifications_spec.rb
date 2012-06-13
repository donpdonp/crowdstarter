require "spec_helper"

describe Notifications do
  describe "thanks" do

    before(:each) do
      @user = mock_model(User, {username: "testuser", email: "em@ail.com"})
      @project = mock_model(Project, {name: "My Test Project"})
      @contribution = Contribution.new

      @contribution.should_receive(:user).and_return(@user)
      @contribution.should_receive(:project).and_return(@project)
      @contribution.should_receive(:amount).and_return(29.95)
    end

    it "renders the headers" do
      mail = Notifications.contribution_thanks(@contribution)

      mail.subject.should eq("Contribution: My Test Project")
      mail.to.should eq(["em@ail.com"])
      mail.from.should eq([SETTINGS.notices.from])
    end

    it "renders the body" do
      mail = Notifications.contribution_thanks(@contribution)

      mail.body.encoded.should match(/contribution of \$29.95/)
    end
  end

end
