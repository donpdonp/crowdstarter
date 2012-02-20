require "spec_helper"

describe Notifications do
  describe "thanks" do
    # create user, project, and contribution
    let(:mail) { pending Notifications.thanks(@contribution) }

    it "renders the headers" do
      pending
      mail.subject.should eq("Thanks for your donation!")
      mail.to.should eq([@contribution.user.email])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      pending
      mail.body.encoded.should match("Hi")
    end
  end

end
